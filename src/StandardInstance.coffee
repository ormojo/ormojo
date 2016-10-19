Instance = require './Instance'
{ isPrimitive } = require './Util'

# Attaches properties to the instance class prototype so that dot-access to
# declared model fields automatically calls getters as needed.
applyModelPropsToInstanceClass = (boundModel, clazz) ->
	for k,v of boundModel.instanceProps when v
		do (k,v) ->
			Object.defineProperty(clazz.prototype, k, {
				enumerable: true, configurable: true
				get: -> @get(k)
				set: (val) -> @set(k, val)
			})
	undefined

# Creates a standard `BoundInstance` class for the given `BoundModel`
createStandardInstanceClassForBoundModel = (bm) ->
	# Instance class for third-party `BoundModel`s that provides default implementations
	# of essential functionality.
	class BoundInstance extends Instance
		# @private
		constructor: (boundModel, @dataValues = {}) ->
			super(boundModel)
			@_previousDataValues = {}

		# @see Instance#getDataValue
		getDataValue: (key) -> @dataValues[key]

		# @see Instance#setDataValue
		setDataValue: (key, value) ->
			originalValue = @dataValues[key]
			if (not isPrimitive(value)) or (value isnt originalValue)
				if not (key of @_previousDataValues) then @_previousDataValues[key] = originalValue
			@dataValues[key] = value
			undefined

		# @see Instance#get
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

		# @see Instance#set
		set: (key, value) ->
			if (value isnt undefined)
				# Run single setter, if exists.
				if @boundModel.instanceProps[key]
					if (setter = @boundModel.setters[key])
						setter.call(@, key, value)
					else
						@setDataValue(key, value)
			else
				# Run setters for each key.
				@set(k,v) for k,v of key when @boundModel.instanceProps[k]
				undefined

		# @see Instance#changed
		changed: (key) ->
			if key
				if (key of @_previousDataValues) then true else false
			else
				changes = (key for key of @dataValues when (key of @_previousDataValues))
				if changes.length > 0 then changes else false

		# @see Instance#save
		save: ->
			@boundModel.backend.save(@, @boundModel)

		# @see Instance#destroy
		destroy: ->
			@boundModel.backend.destroy(@, @boundModel)

	# Create getters and setters
	applyModelPropsToInstanceClass(bm, BoundInstance)

	# Return the instance class
	BoundInstance

module.exports = {
	applyModelPropsToInstanceClass
	createStandardInstanceClassForBoundModel
}
