import Reducible from './Reducible'

export default class Hydrator extends Reducible
	constructor: (options) ->
		@initialize(options)

	initialize: (options = {}) ->
		@instances = Object.create(null)
		bm = @boundModel = options.boundModel
		@createInstance = options.createInstance or (-> bm.createInstance())
		@shouldClearChanges = options.shouldClearChanges

	filter: (instance) ->
		true

	getById: (id) ->
		@instances[id]

	forEach: (func, thisArg) ->
		if thisArg is undefined
			func(v, k) for k, v of @instances
		else
			func.call(thisArg, v, k) for k,v of @instances
		undefined

	createOptimisticInstance: (id) ->
		if (instance = @instances[id]) then return instance
		instance = @createInstance()
		instance.id = id
		instance.isOptimistic = true
		@instances[id] = instance
		instance

	_createUpdateAction: (entity, created, updated, deleted) ->
		if entity.id of @instances
			# Update the extant instance with the data values.
			instance = @instances[entity.id]
			instance._setDataValues(entity)
			delete instance.isOptimistic
			if @shouldClearChanges then instance._clearChanges()
			# If it passes the filter, mark it as updated; else discard it.
			if @filter(instance)
				updated.push(instance)
			else
				delete @instances[entity.id]
				instance.wasDeleted = true
				deleted.push(instance)
		else
			# Create the instance; if it passes the filter, keep it.
			nonceInstance = @createInstance()
			nonceInstance._setDataValues(entity)
			if @filter(nonceInstance)
				@instances[nonceInstance.id] = nonceInstance
				created.push(nonceInstance)

	_deleteAction: (id, deleted) ->
		if id of @instances
			instance = @instances[id]
			delete @instances[id]
			instance.wasDeleted = true
			deleted.push(instance)

	reduce: (action) ->
		created = []
		updated = []
		deleted = []
		reset = false
		switch action.type
			# For each updated ID:
			#  - If it exists in the Map, update its values, check against filter, delete if fails.
			#  - If it doesn't exist in the Map, behave like CREATE.
			when 'CREATE', 'UPDATE'
				@_createUpdateAction(entity, created, updated, deleted) for entity in action.payload

			when 'DELETE'
				@_deleteAction(id, deleted) for id in action.payload

			when 'RESET'
				reset = true
				# We have to reset the hydrated instances to look like the store.
				if (store = action.meta?.store)
					# Touch all the entities that exist in the anterior store, then
					# update the dataValues to reflect the store state.
					touched = {}
					store.forEach (entity, id) =>
						touched[id] = true
						@_createUpdateAction(entity, created, updated, deleted)
					# Delete all untouched entities
					list = (k for k,v of @instances when not (k of touched))
					@_deleteAction(id, deleted) for id in list
				else
					# There was no anterior store -- total wipeout.
					@_deleteAction(id, deleted) for id of @instances
					@instances = Object.create(null)

			else
				throw new Error('Hydrator only supports CRUD actions.')

		return {
			type: action.type
			meta: Object.assign {}, action.meta, {
				hydrator: @
				store: @
				lastHydration: {
					created, updated, deleted, reset
				}
			}
			payload: action.payload
		}
