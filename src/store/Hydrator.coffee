# Converts raw JSON data from the Store into ormojo instances, and vice versa.
export default class Hydrator
	constructor: ({@boundModel}) ->
		@backend = @boundModel.backend
		@corpus = @boundModel.corpus

	# Given an optional Instance and data from `Store.read`, update the instance's
	# internal state appropriately. If no Instance is given, it should be created
	# from scratch.
	didRead: (instance, data) ->
		if data is undefined then return undefined
		if instance
			@didUpdate(instance, data)
		else
			@boundModel.createInstance(data)

	# Given an Instance, return data values suitable for use with `Store.create`
	willCreate: (instance) ->
		instance._getDataValues()

	# Given an Instance and data from Store.create, update the instance's
	# internal structure appropriately.
	didCreate: (instance, data) ->
		@didUpdate(instance, data)

	# Given an Instance, return data values suitable for use with `Store.update` or
	# `Store.upsert` which will upload the desired future state of the Instance to
	# the Store.
	willUpdate: (instance) ->
		instance._getDataValues()

	didUpdate: (instance, data) ->
		instance._setDataValues(data)
		instance._clearChanges()
		instance

	willDelete: (instance) ->
		instance.id

	didDelete: (instance) ->
		instance.wasDeleted = true
		instance
