import Reducible from './Reducible'

export default class Collector extends Reducible
	constructor: ->
		super()
		@reset()

	reset: ->
		@byId = Object.create(null)
		@instances = []

	# The Updater is called every time the entities in the Collector's internal
	# store are changed. Use this opportunity to, e.g., sort the data.
	updater: ->

	# Implement Store interface
	getById: (id) -> @byId[id]
	forEach: (func) -> func(v,k) for k,v of @byId; undefined
	getArray: -> @instances

	# Default hydration implementation just fetches the entity, presumably
	# already hydrated, from the anterior store. Overload to perform hydration
	# inside the collector.
	### istanbul ignore next ###
	willCreateEntity: (store, entity) ->
		store.getById(entity.id)
	### istanbul ignore next ###
	willUpdateEntity: (store, previousEntity, entity) ->
		store.getById(entity.id)
	### istanbul ignore next ###
	willDeleteEntity: (store, entity) ->

	_createAction: (store, entity) ->
		storedEntity = @willCreateEntity(store, entity)
		if (not @filter(storedEntity)) then return
		if not (storedEntity.id of @byId)
			@byId[storedEntity.id] = storedEntity
			@instances.push(storedEntity)
		@dirty = true

	_updateAction: (store, entity) ->
		# If the entity is within our store...
		if entity.id of @byId
			previousEntity = @byId[entity.id]
			# Re-up and reapply the filter
			nextEntity = @willUpdateEntity(store, previousEntity, entity)
			if @filter(nextEntity)
				@byId[entity.id] = nextEntity
				@dirty = true
			else
				return @_deleteAction(store, entity)
		else
			# Not in the store, do a create action
			return @_createAction(store, entity)

	_deleteAction: (store, entity, shouldUpdateInstances = true) ->
		if (id = entity.id) of @byId
			@willDeleteEntity(store, @byId[id])
			delete @byId[id]
			if shouldUpdateInstances then @instances = (v for k,v of @byId)
			@dirty = true

	# Update and delete extant entities, based on values from a store.
	_diffUpdateDelete: (store) ->
		# For each extant entity..
		for k,v of @byId
			# If it exists on the remote store...
			if (nextEntity = store.getById(k))
				# Process as an update.
				@_updateAction(store, nextEntity)
			else
				# Remove from local store
				@_deleteAction(store, v, false)
		undefined

	# Create missing entities that exist on the store, but not this collector.
	_diffCreate: (store) ->
		store.forEach (v, k) =>
			if not (k of @byId) then @_createAction(store, v)

	_resetAction: (store) ->
		@dirty = true
		if store?
			# Diff store against self.
			@_diffUpdateDelete(store)
			@_diffCreate(store)
		else
			# Total wipeout
			for k,v of @byId
				@willDeleteEntity(null, v)
				delete @byId[k]
			@instances = []

	augmentAction: (action) -> {
		type: action.type
		meta: Object.assign {}, action.meta, { store: @ }
		payload: action.payload
		error: action.error
	}

	reduce: (action) ->
		# A collector may optionally be connected after another Store, in which case
		# it obtains its values from that store.
		store = action.meta?.store

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
