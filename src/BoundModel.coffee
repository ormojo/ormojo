# A model bound to a backend or backends.
class BoundModel
	constructor: (@model, @backend) ->
		@getters = {}
		@setters = {}
		@instanceProps = {}

		for k,field of @model.fields
			@getters[k] = null
			@setters[k] = null
			@instanceProps[k] = true

		for k,v of model.spec.properties
			if not v
				delete @instanceProps[k]
			else
				@getters[k] = v.get
				@setters[k] = v.set
				@instanceProps[k] = true



module.exports = BoundModel
