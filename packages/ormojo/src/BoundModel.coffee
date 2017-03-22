import mergeOptions from 'merge-options'
import Field from './Field'
import { createStandardInstanceClassForBoundModel } from './StandardInstance'

# A model bound to a backend or backends.
export default class BoundModel
	# Should only be called by Backend.bindModel
	# @private
	constructor: (@model, @backend, bindingOptions) ->
		# Basic demographics
		@corpus = @model.corpus; @name = @model.name
		# Construct spec from model spec + binding options
		@spec = mergeOptions(@model.spec, bindingOptions or {})
		@_deriveFields()
		@_deriveProperties()
		@initialize()
		@_deriveInstanceClass()
		@_deriveInstanceClassProperties()

	# Derive fields from spec.
	# @private
	_deriveFields: ->
		@fields = {}
		for k,fieldSpec of @spec.fields
			f = new Field().fromSpec(k, fieldSpec)
			@fields[k] = f
		# prevent comprehension
		undefined

	# Derive getters and setters from spec.
	# @private
	_deriveProperties: ->
		@getters = {}; @setters = {}; @instanceProps = {}

		for k,field of @fields
			@getters[k] = field.get; @setters[k] = field.set; @instanceProps[k] = true

		# Pure properties (getter/setter only)
		for k,v of (@spec.properties or {})
			if not v
				delete @instanceProps[k]
			else
				@getters[k] = v.get; @setters[k] = v.set; @instanceProps[k] = true
		# prevent comprehension
		undefined

	# Perform initialization after the spec has been read.
	initialize: ->
		@instanceClass = createStandardInstanceClassForBoundModel(@)

	_deriveInstanceClass: ->

	_deriveInstanceClassProperties: ->
		for name,method of (@spec.statics or {})
			Object.defineProperty(@, name, {
				configurable: true, enumerable: false, writable: true
				value: method
			})
		for name,method of (@spec.methods or {})
			Object.defineProperty(@instanceClass.prototype, name, {
				configurable: true, enumerable: false, writable: true
				value: method
			})
		undefined


	# Retrieves a hash of fields by name.
	#
	# @return [Object<String, Field>] An Object whose keys are the names of the respective fields, with values the corresponding `Field` objects.
	getFields: ->
		@fields

	# Create a query targeted at this boundModel.
	createQuery: ->
		@store.createQuery()

	# Create a raw instance of this boundModel with the given dataValues.
	# Synchronous and does not interact with the persistence framework.
	# Generally only backends should be calling this method; you probably want
	# `BoundModel.create()`.
	createInstance: (dataValues, metadata) ->
		new @instanceClass(@, dataValues, metadata)

	# Create a new instance
	#
	# @overload create()
	#   Create a new instance which is not persisted to the database. This method is synchronous.
	#   @return [Instance] The new instance.
	#
	#	@overload create(data)
	#   Create a new instance which will be immediately persisted to the database. This method is asynchronous
	#   @param data [Object] Initial data for the instance. This data will be merged to the instance as with `Instance.set()`, calling all setters as needed.
	#   @return [Promise<Instance>] A `Promise` whose fate is settled depending on whether the Instance was persisted to the database.
	create: (data) ->
		instance = @createInstance()
		instance.isNewRecord = true
		instance._applyDefaults()
		if data isnt undefined
			instance.set(data)
			instance.save()
		else
			instance

	# Invoked when an `Instance` wants to persist itself to the backend.
	#
	# @abstract
	# @param instance [Instance] The `Instance` to be persisted
	#
	# @return [Promise<Instance>] A `Promise` whose fate is settled depending on the performance of the save operation. If the save operation succeeds, it should resolve with the updated Instance.
	save: (instance) ->
		if instance.isNewRecord
			@put(instance, true)
		else
			@put(instance, false)

	# Attempt to persist the given Instance to the backing store.
	#
	# @param instance [Instance] Raw data for the instance.
	# @return [Promise<Instance>] A `Promise` of the instance
	put: (instance, shouldCreate = true) ->
		if shouldCreate
			@store.create([ @hydrator.willCreate(instance) ])
			.then (createdData) =>
				@hydrator.didCreate(instance, createdData[0])
		else
			@store.update([ @hydrator.willUpdate(instance) ])
			.then (updatedData) =>
				@hydrator.didUpdate(instance, updatedData[0])

	# Invoked to destroy an object from persistent storage by id.
	#
	# @abstract
	# @param id [String|Integer] The id of the object to be deleted from the store.
	#
	# @return [Promise<Boolean>] A `Promise` whose fate is settled depending on the performance of the operation, and whose value is true if an instance with the given id existed and was deleted, or false otherwise.
	destroyById: (id) ->
		@store.delete([id])
		.then (rst) -> rst[0]

	### istanbul ignore next ###

	# Invoked when an `Instance` wants to delete from the backend.
	#
	# @abstract
	# @param instance [Instance] The `Instance` to be deleted
	#
	# @return [Promise<Boolean>] A `Promise` whose fate is settled depending on the performance of the operation, and whose value is true if an instance existed and was deleted, or false otherwise.
	destroy: (instance) ->
		@store.delete([ @hydrator.willDelete(instance) ])
		.then (rst) =>
			if rst?[0] then @hydrator.didDelete(instance) else instance

	### istanbul ignore next ###

	# Retrieve an instance from the backing store from id or ids.
	#
	# @overload findById(id)
	#   Locate a single instance by id.
	#   @param id [String | Number] The id of the `Instance` as understood by the backing store.
	#   @return [Promise<Instance>] A `Promise` of the `Instance` with the given id, if found. If not found, the `Promise` will resolve with the value `undefined`. The `Promise` is only rejected in the event of a database error.
	#
	# @overload findById(ids)
	#   Locate multiple instances given a list of ids.
	#   @param id [Array<String | Number>] The ids of the `Instance`s as understood by the backing store.
	#   @return [Promise< Array<Instance> >] A `Promise` of an array whose entries correspond to the entries of the `ids` array. In each position, the array will contain the `Instance` with the given id, if found. If not found, the entry will be `undefined`. The `Promise` is only rejected in the event of a database error.
	findById: (id) ->
		multiple = Array.isArray(id)
		@findAll(@createQuery().byId(id))
		.then (resultSet) ->
			if multiple
				resultSet.getResults()
			else
				(resultSet.getResults())[0]

	### istanbul ignore next ###

	# Retrieve a single instance from the backing store using query options.
	#
	# @param query [query] A Query created by `this.createQuery()`.
	# @return [Promise<Instance>] A `Promise` of the `Instance` matching the query, if found. If not found, the `Promise` will resolve with the value `undefined`. The `Promise` is only rejected in the event of a database error.
	find: (query) ->
		query.setLimit(1)
		@findAll(query)
		.then (resultSet) ->
			if resultSet.isEmpty()
				undefined
			else
				(resultSet.getResults())[0]

	### istanbul ignore next ###

	# Retrieve many instances from the backing store using query options.
	#
	# @param querySpec [Object] Query options. *NB* Not all backends need support all options. See the documentation for your backend for specifics.
	# @return [Promise<ResultSet>] A `Promise` of the `ResultSet` matching the query
	findAll: (query) ->
		@store.read(query)
		.then (resultSet) =>
			resultSet._hydrateResults(@hydrator)
			resultSet
