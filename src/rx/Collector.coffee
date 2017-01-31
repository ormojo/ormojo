import Reducible from './Reducible'

export default class Collector extends Reducible
	constructor: ->
		super()
		@reset()

	reset: ->
		@byId = {}
		@instances = []

	updater: ->

	# Implement Store interface
	getById: (id) -> @byId[id]
	forEach: (func) -> func(v,k) for k,v of @byId; undefined
	getArray: -> @instances

	_createAction: (store, entity) ->
		if not @filter(entity) then return
		if not (entity.id of @byId)
			storedEntity = store.getById(entity.id)
			@byId[entity.id] = storedEntity; @instances.push(storedEntity)
		@dirty = true

	_updateAction: (store, entity) ->
		# If passes filter...
		if @filter(entity)
			# Create if non present
			if not (entity.id of @byId) then return @_createAction(store, entity)
			# Else trigger update
			@dirty = true
		else
			if entity.id of @byId then return @_deleteAction(store, entity)

	_deleteAction: (store, entity) ->
		if entity.id of @byId
			delete @byId[id]
			@instances = (v for k,v of @byId)
			@dirty = true

	_resetAction: (store) ->
		@reset()
		store.forEach (v,k) =>
			@byId[k] = v; @instances.push(v)
		@dirty = true

	augmentAction: (action) -> {
		type: action.type
		meta: Object.assign {}, action.meta, { store: @ }
		payload: action.payload
		error: action.error
	}

	reduce: (action) ->
		# Collectors must be connected after Stores.
		store = action.meta?.store
		if not store then throw new Error('Collector must be connected after a Store')

		switch action.type
			when 'CREATE'
				@_createAction(store, entity) for entity in action.payload
			when 'UPDATE'
				@_updateAction(store, entity) for entity in action.payload
			when 'DELETE'
				@_deleteAction(store, entity) for entity in action.payload
			when 'RESET'
				@_resetAction(store)
			else
				return action

		if @dirty then @updater(); @dirty = false
		@augmentAction(action)
