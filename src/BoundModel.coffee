mergeOptions = require 'merge-options'
Field = require './Field'

# A model bound to a backend or backends.
class BoundModel
	# Should only be called by Backend.bindModel
	# @private
	constructor: (@model, @backend, bindingOptions) ->
		# Basic demographics
		@corpus = @model.corpus; @name = @model.name
		# Construct spec from model spec + binding options
		@spec = mergeOptions(@model.spec, bindingOptions or {})
		@_deriveFields()
		@_deriveProperties()

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

	# Retrieves a hash of fields by name.
	#
	# @return [Object<String, Field>] An Object whose keys are the names of the respective fields, with values the corresponding `Field` objects.
	getFields: ->
		@fields

	# Create an empty instance of this boundModel.
	# @private
	_createInstance: (dataValues) ->
		new @instanceClass(@, dataValues)

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
		instance = @_createInstance()
		instance.isNewRecord = true
		instance.__applyDefaults()
		if data isnt undefined
			instance.set(data)
			instance.save()
		else
			instance

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
		@backend.findById(@, id)

	# Retrieve a single instance from the backing store using query options.
	#
	# @param options [Object] Query options. *NB* Not all backends need support all options.
	# @return [Promise<Instance>] A `Promise` of the `Instance` matching the query, if found. If not found, the `Promise` will resolve with the value `undefined`. The `Promise` is only rejected in the event of a database error.
	find: (options) ->
		@backend.find(@, options)

	# Retrieve many instances from the backing store using query options.
	#
	# @param options [Object] Query options. *NB* Not all backends need support all options.
	# @option options [Number] offset Offset for pagination.
	# @option options [Number] limit Limit (number of entries per page) for pagination.
	# @option options [Cursor] cursor A `Cursor` object returned by a previous `findAll` operation. If passed, this operation will retrieve the next page. *NB* Passing a pagination object may override other query options in an attempt to match your query against the one that generated the pagination.
	# @return [Promise<Results>]
	findAll: (options) ->
		@backend.findAll(@, options)

module.exports = BoundModel
