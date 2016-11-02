import Instance from './Instance'
import { isPrimitive } from './Util'

# Instance class for third-party `BoundModel`s that provides default implementations
# of essential functionality.
export default class BoundInstance extends Instance
	# @private
	constructor: (boundModel, @dataValues = {}) ->
		super(boundModel)

	# @see Instance#getDataValue
	getDataValue: (key) -> @dataValues[key]

	# @see Instance#setDataValue
	setDataValue: (key, value) ->
		originalValue = @dataValues[key]
		# If value is different or not comparable...
		if (not isPrimitive(value)) or (value isnt originalValue)
			# Create diff cache if needed...
			if not @_previousDataValues then @_previousDataValues = Object.create(null)
			# Add key to diff cache
			if not (key of @_previousDataValues) then @_previousDataValues[key] = originalValue
		@dataValues[key] = value
		undefined

	# Notify that data values are in sync with the most recent database call.
	_clearChanges: ->
		delete @isNewRecord
		delete @_previousDataValues

	# Get raw data values as an immutable JS object.
	_getDataValues: -> @dataValues

	# Set raw data values from a JS object.
	_setDataValues: (@dataValues) ->

	# Merge raw data values from an external source.
	_mergeDataValues: (source) ->
		Object.assign(@dataValues, source)

	# @see Instance#get
	get: (key) ->
		if key and (key of @boundModel.instanceProps)
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
			if key and (key of @boundModel.instanceProps)
				if (setter = @boundModel.setters[key])
					setter.call(@, key, value)
				else
					@setDataValue(key, value)
		else
			# Run setters for each key.
			@set(k,v) for k,v of key when k of @boundModel.instanceProps
			undefined

	# @see Instance#changed
	changed: (key) ->
		if key
			if @_previousDataValues and (key of @_previousDataValues) then true else false
		else
			if not @_previousDataValues then return false
			changes = (key for key of @dataValues when (key of @_previousDataValues))
			if changes.length > 0 then changes else false

	# @see Instance#save
	save: ->
		@boundModel.save(@)

	# @see Instance#destroy
	destroy: ->
		@boundModel.destroy(@)
