class Backend
	constructor: ->

	_initialize: (@corpus, @name) -> @initialize()

	initialize: ->

	#
	# bindModel: (model: Model) -> BoundModel
	#
	# Invoked when a model is attempted to be bound to this backend.
	# This is the correct time to throw Errors for models that are outright incompatible with this
	# backend.
	#
	bindModel: (model) ->
		throw new Error('Backend: `bindModel` called on abstract backend.')

	# Invoked when an instance wants to save
	saveInstance: (instance, boundModel) ->
		@corpus.promiseReject(new Error('Backend: saveInstance called on abstract backend.'))

	# Invoked when an instance wants to destroy
	destroyInstance: (instance, boundModel) ->
		@corpus.promiseReject(new Error('Backend: destroyInstance called on abstract backend.'))

	# Create a raw un-persisted instance.
	createRawInstance: (boundModel, dataValues) ->
		throw new Error('Backend: `createRawInstance` called on abstract backend.')

	#
	# Create a new instance.
	# If called with initialData, the method is asynchronous and persists to the DB.
	# If initialData is undefined, the method is synchronous and returns a fresh instance.
	#
	createInstance: (boundModel, initialData) ->
		err = new Error('Backend: createInstance called on abstract backend.')
		if initialData is undefined
			throw err
		else
			@corpus.promiseReject(err)

	findInstanceById: (boundModel, id) ->
		@corpus.promiseReject(new Error('Backend: `findInstanceById` called on abstract backend.'))


module.exports = Backend
