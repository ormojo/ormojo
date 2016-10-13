Instance = require './Instance'

isPrimitive = (v) ->
	t = typeof(v)
	if (t is 'string') or (t is 'number') or (t is 'boolean') then true else false

createStandardInstanceClassForBoundModel = (bm) ->
	class BMInstance extends Instance
		constructor: (boundModel) ->
			super(boundModel)
			@dataValues = {}
			@_previousDataValues = {}

		getDataValue: (key) -> @dataValues[key]

		setDataValue: (key, value) ->
			originalValue = @dataValues[key]
			if (not isPrimitive(value)) or (value isnt originalValue)
				if not (key of @_previousDataValues) then @_previousDataValues[key] = originalValue
			@dataValues[key] = value

		get: (key) ->
			if key and @boundModel.instanceProps[key]
				if (getter = @boundModel.getters[key])
					getter.call(@, key)
				else
					@getDataValue(key)
			else
				values = {}
				for k of @boundModel.instanceProps
					values[k] = @get(k)
				values

		changed: (key) ->
			if key
				if (key of @_previousDataValues) then true else false
			else
				changes = (key for key of @dataValues when (key of @_previousDataValues))
				if changes.length > 0 then changes else false


	# Create getters and setters
	for k,v of model.instanceProps when v
		Object.defineProperty(ModelInstance.prototype, k, {
			enumerable: true, configurable: true
			get: -> @get(k)
			set: (val) -> @set(k, val)
		})

	# Don't let coffeescript make a comprehension
	undefined

module.exports = {
	createStandardInstanceClassForBoundModel
}
