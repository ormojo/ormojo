import Instance from './Instance'
import { isPrimitive } from './Util'

# Instance class for third-party `BoundModel`s that provides default implementations
# of essential functionality.
export default class BoundInstance extends Instance
	# @private
	constructor: (boundModel, @dataValues = {}) ->
		super(boundModel)

	# @see Instance#getDataValue
	getDataValue: (key) ->
		if @_nextDataValues and (key of @_nextDataValues) then @_nextDataValues[key] else @dataValues[key]

	# @see Instance#setDataValue
	setDataValue: (key, value) ->
		originalValue = @dataValues[key]
		# If value is different or not comparable...
		if (not isPrimitive(value)) or (value isnt originalValue)
			# Create diff cache if needed...
			if not @_nextDataValues then @_nextDataValues = Object.create(null)
			# Add key to diff cache
			@_nextDataValues[key] = value
		undefined

	# Notify that data values are in sync with the most recent database call.
	_clearChanges: ->
		delete @isNewRecord
		delete @_nextDataValues

	# Get raw data values as an immutable JS object. This represents the user's
	# DESIRED FUTURE STATE of the object, for persistence to the store.
	_getDataValues: ->
		if @_nextDataValues
			Object.assign({}, @dataValues, @_nextDataValues)
		else
			@dataValues

	# Set raw data values from a JS object.
	_setDataValues: (@dataValues) -> undefined

	# Merge raw data values from a JS object.
	_mergeDataValues: (nextDataValues) ->
		Object.assign(@dataValues, nextDataValues)

	# @see Instance#get
	get: (key) ->
		if not @boundModel then return # this can be called on the Prototype by weird libraries...
		if key and (key of @boundModel.instanceProps)
			if (getter = @boundModel.getters[key])
				getter.call(@, key)
			else
				@getDataValue(key)
		else
			values = {}
			values[k] = @get(k) for k of @boundModel.instanceProps
			values

	# @see Instance#set
	set: (key, value) ->
		if not @boundModel then return # this can be called on the Prototype by weird libraries...
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
		if key isnt undefined
			if @_nextDataValues and (key of @_nextDataValues) then true else false
		else
			if not @_nextDataValues then return false
			#changes = (key for key of @dataValues when (key of @_nextDataValues))
			changes = (key for key of @_nextDataValues)
			if changes.length > 0 then changes else false

	# @see Instance#save
	save: ->
		@boundModel.save(@)

	# @see Instance#destroy
	destroy: ->
		@boundModel.destroy(@)
