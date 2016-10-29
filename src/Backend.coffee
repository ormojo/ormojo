# Driver that intermediates between the ormojo API and some underlying data layer.
class Backend
	# Construct a backend. Generally, initialization work for the backend should not be
	# performed here, but rather in `.initialize`
	#
	# @see Backend#initialize
	constructor: ->

	# @private
	_initialize: (@corpus, @name) -> @initialize()

	### !pragma coverage-skip-next ###

	# Initialize a Backend that has been added to a Corpus.
	initialize: ->

	### !pragma coverage-skip-next ###

	# Invoked when a model is being bound to this backend.
	# Errors thrown from this method indicate that a Model is incompatible with this
	# particular backend.
	#
	# @abstract
	# @param [Model] model The model to bind to this backend.
	bindModel: (model) ->
		throw new Error('Backend: `bindModel` called on abstract backend.')

	### !pragma coverage-skip-next ###

	# Invoked when an `Instance` wants to persist itself to the backend.
	#
	# @abstract
	# @param instance [Instance] The `Instance` to be persisted
	# @param boundModel [BoundModel] The `BoundModel` that created the `Instance`.
	#
	# @return [Promise<Instance>] A `Promise` whose fate is settled depending on the performance of the save operation. If the save operation succeeds, it should resolve with the updated Instance.
	save: (instance, boundModel) ->
		@corpus.Promise.reject(new Error('Backend: saveInstance called on abstract backend.'))

	### !pragma coverage-skip-next ###

	# Invoked when an `Instance` wants to delete from the backend.
	#
	# @abstract
	# @param instance [Instance] The `Instance` to be deleted
	# @param boundModel [BoundModel] The `BoundModel` that created the `Instance`.
	#
	# @return [Promise<undefined>] A `Promise` whose fate is settled depending on the performance of the operation.
	destroy: (instance, boundModel) ->
		@corpus.Promise.reject(new Error('Backend: destroyInstance called on abstract backend.'))

	### !pragma coverage-skip-next ###

	# Retrieve an instance from the backing store from id or ids.
	#
	# @abstract
	# @see BoundModel#findById
	findById: (boundModel, id) ->
		@corpus.Promise.reject(new Error('Backend: `findById` called on abstract backend.'))

	### !pragma coverage-skip-next ###

	# Retrieve a single instance from the backing store using query options.
	#
	# @abstract
	# @see BoundModel#find
	find: (boundModel, options) ->
		@corpus.Promise.reject(new Error('Backend: `find` called on abstract backend.'))

	### !pragma coverage-skip-next ###

	# Retrieve many instances from the backing store using query options.
	#
	# @abstract
	# @see BoundModel#findAll
	findAll: (boundModel, options) ->
		@corpus.Promise.reject(new Error('Backend: `findAll` called on abstract backend.'))

module.exports = Backend
