# A model bound to a backend or backends.
class BoundModel
	constructor: (@model, @backend) ->
		@corpus = @model.corpus
		@name = @model.name
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
		@backend.createInstance(@, data)

	findById: (id) ->
		@backend.findInstanceById(@, id)

module.exports = BoundModel
