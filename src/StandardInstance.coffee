Instance = require './Instance'

isPrimitive = (v) ->
	t = typeof(v)
	if (t is 'string') or (t is 'number') or (t is 'boolean') then true else false

createStandardInstanceClassForBoundModel = (bm) ->
	class BoundInstance extends Instance
		constructor: (boundModel, @dataValues = {}) ->
			super(boundModel)
			@_previousDataValues = {}

		getDataValue: (key) -> @dataValues[key]

		setDataValue: (key, value) ->
			originalValue = @dataValues[key]
			if (not isPrimitive(value)) or (value isnt originalValue)
				if not (key of @_previousDataValues) then @_previousDataValues[key] = originalValue
			@dataValues[key] = value

		get: (key) ->
			if key
				if @boundModel.instanceProps[key]
					if (getter = @boundModel.getters[key])
						getter.call(@, key)
					else
						@getDataValue(key)
			else
				values = {}
				for k of @boundModel.instanceProps
					values[k] = @get(k)
				values

		set: (key, value) ->
			if (value isnt undefined)
				if @boundModel.instanceProps[key]
					if (setter = @boundModel.setters[key])
						setter.call(@, key, value)
					else
						@setDataValue(key, value)
			else
				for k,v of key when @boundModel.instanceProps[k]
					@set(k,v)

		changed: (key) ->
			if key
				if (key of @_previousDataValues) then true else false
			else
				changes = (key for key of @dataValues when (key of @_previousDataValues))
				if changes.length > 0 then changes else false

		save: ->
			@boundModel.backend.saveInstance(@, @boundModel)

		destroy: ->
			@boundModel.backend.destroyInstance(@, @boundModel)

	# Create getters and setters
	for k,v of bm.instanceProps when v
		do (k,v) ->
			Object.defineProperty(BoundInstance.prototype, k, {
				enumerable: true, configurable: true
				get: -> @get(k)
				set: (val) -> @set(k, val)
			})

	# Return the instance class
	BoundInstance

module.exports = {
	createStandardInstanceClassForBoundModel
}
