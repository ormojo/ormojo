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

	# Retrieves a hash of fields by name.
	#
	# @return [Object<String, Field>] An Object whose keys are the names of the respective fields, with values the corresponding `Field` objects.
	getFields: ->
		@fields

	# @see Model#create
	create: (data) ->
		@backend.create(@, data)

	# @see Model#findById
	findById: (id) ->
		@backend.findById(@, id)

	# @see Model#find
	find: (options) ->
		@backend.find(@, options)

	# @see Model#findAll
	findAll: (options) ->
		@backend.findAll(@, options)

module.exports = BoundModel
