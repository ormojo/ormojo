Instance = require './Instance'
{ isPrimitive } = require './Util'

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

	# Notify that data values are in sync with the most recent database call.
	_clearChanges: ->
		@_previousDataValues = {}

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

module.exports = BoundInstance
