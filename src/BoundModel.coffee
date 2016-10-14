# A model bound to a backend or backends.
class BoundModel
	constructor: (@model, @backend) ->
		# Basic demographics
		@corpus = @model.corpus; @name = @model.name
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

	create: (data) ->
		@backend.create(@, data)

	findById: (id) ->
		@backend.findById(@, id)

	find: (options) ->
		@backend.find(@, options)

	findAll: (options) ->
		@backend.findAll(@, options)

module.exports = BoundModel
