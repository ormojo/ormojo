# A model bound to a backend or backends.
class BoundModel
	# Should only be called by Backend.bindModel
	# @private
	constructor: (@model, @backend) ->
		# Basic demographics
		@corpus = @model.corpus; @name = @model.name; @fields = @model.fields
		# Construct spec from model spec + backend name
		@spec = {}
		@spec.backend = @model.spec.backends?[@backend.name]

		@getters = {}
		@setters = {}
		@instanceProps = {}

		for k,field of @model.fields
			@getters[k] = null
			@setters[k] = null
			@instanceProps[k] = true

		for k,v of (@model.spec.properties or {})
			if not v
				delete @instanceProps[k]
			else
				@getters[k] = v.get
				@setters[k] = v.set
				@instanceProps[k] = true

	# Retrieves a hash of fields by name.
	#
	# @return [Object<String, Field>] An Object whose keys are the names of the respective fields, with values the corresponding `Field` objects.
	getFields: -> @fields

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
