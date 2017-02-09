import Instance from './Instance'
import { isPrimitive } from './Util'
import { defineObservableSymbol, removeFromList } from './rx/RxUtil'
import Observable from './rx/Observable'

# Instance class for third-party `BoundModel`s that provides default implementations
# of essential functionality.
export default class BoundInstance extends Instance
	# @private
	constructor: (boundModel, @dataValues = {}) ->
		super(boundModel)

	# @see Instance#getDataValue
	getDataValue: (key) ->
		# _nextDataValues holds optimistic updates to the instance. Query it first; fallback to dataValues.
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
			# Notify wasUpdated
			@_wasUpdated()
		undefined

	# Notify that data values are in sync with the most recent database call.
	_clearChanges: ->
		delete @isNewRecord
		delete @_nextDataValues

	# Get raw data values as an immutable JS object. This represents the user's
	# DESIRED FUTURE STATE of the object, for persistence to the store.
	_getDataValues: ->
		if @_nextDataValues
			# Flatten dataValues together with optimistic updates.
			Object.assign({}, @dataValues, @_nextDataValues)
		else
			@dataValues

	# Set raw data values from a JS object.
	# @private
	_setDataValues: (@dataValues) ->
		@_wasUpdated()

	# Merge raw data values from a JS object.
	# @private
	_mergeDataValues: (nextDataValues) ->
		Object.assign(@dataValues, nextDataValues)
		@_wasUpdated()

	# Invoked when this object was updated.
	_wasUpdated: ->
		if @_observers
			observer.next(@) for observer in @_observers
		undefined

	# @see Instance#get
	get: (key) ->
		# Some libraries call this on the Prototype; early out in that case.
		### istanbul ignore if ###
		if not @boundModel then return
		if key isnt undefined
			# Get value for the given prop.
			if (key of @boundModel.instanceProps)
				if (getter = @boundModel.getters[key])
					getter.call(@, key)
				else
					@getDataValue(key)
		else
			# Get all values.
			values = {}
			values[k] = @get(k) for k of @boundModel.instanceProps
			values

	# @see Instance#set
	set: (key, value) ->
		# Some libraries call this on the Prototype; early out in that case.
		### istanbul ignore if ###
		if not @boundModel then return
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

# Observability for BoundInstances
defineObservableSymbol(BoundInstance.prototype, ->
	if @_observable then return @_observable
	instance = @
	### istanbul ignore else ###
	if not instance._observers then instance._observers = []
	@_observable = new Observable (observer) ->
		instance._observers.push(observer)
		-> removeFromList(instance._observers, observer)
)
