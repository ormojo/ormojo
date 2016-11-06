import Reducible from './Reducible'

export default class Sorter extends Reducible
	constructor: ->
		@reset()

	reset: ->
		@byId = {}
		@instances = []

	filter: -> true
	actionFilter: -> true

	# Implement Store interface
	getById: (id) -> @byId[id]
	forEach: (func) -> func(v,k) for k,v of @byId; undefined
	getArray: -> @instances

	_createAction: (entity) ->
		if not @filter(entity) then return
		if not (entity.id of @byId)
			@byId[entity.id] = entity; @instances.push(entity)
		@dirty = true

	_updateAction: (entity) ->
		# If passes filter...
		if @filter(entity)
			# Create if non present
			if not (entity.id of @byId) then return @_createAction(entity)
			# Else trigger update
			@dirty = true
		else
			if entity.id of @byId then return @_deleteAction(entity)

	_deleteAction: (entity) ->
		if entity.id of @byId
			delete @byId[id]
			@instances = (v for k,v of @byId)
			@dirty = true

	augmentAction: (action) -> {
		type: action.type
		meta: Object.assign {}, action.meta, { store: @ }
		payload: action.payload
	}

	reduce: (action) ->
		# Do nothing if action doesn't pass our filter.
		if not @actionFilter(action) then return action

		# Collectors must be connected after Stores.
		store = action.meta?.store
		if not store then throw new Error('Collector must be connected after a Store')

		switch action.type
			when 'CREATE'
				@_createAction(entity) for entity in action.payload
			when 'UPDATE'
				@_updateAction(entity) for entity in action.payload
			when 'DELETE'
				@_deleteAction(entity) for entity in action.payload
			else
				return action

		if @dirty then @updater(); @dirty = false
		@augmentAction(action)
