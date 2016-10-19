Field = require './Field'

# Declarative representation of a model.
class Model
	# Constructor should only be called by `Corpus.createModel()`.
	# @private
	# @see Corpus#createModel
	constructor: (@corpus, @spec) ->
		@name = @spec.name

		@fields = {}; @fieldsList = []
		for k,fspec of @spec.fields
			f = new Field()
			f.fromSpec(k, fspec)
			@fields[k] = f; @fieldsList.push(f)

	# @private
	_forBackend: (backend) -> backend.bindModel(@)

	# Bind this model to the backend in the `Corpus` with the given name.
	#
	# @param backendName [String] Name of a valid backend in the `Corpus` containing this model.
	# @return [BoundModel] A BoundModel tying this model to the given backend.
	forBackend: (backendName) -> @_forBackend(@corpus.getBackend(backendName))

	# @private
	_defaultBinding: ->
		if @_defaultBound
			@_defaultBound
		else
			@_defaultBound = @_forBackend(@corpus.getDefaultBackendForModel(@))

	# Create a new instance
	#
	# @overload create()
	#   Create a new instance which is not persisted to the database. This method is synchronous.
	#   @return [Instance] The new instance.
	#
	#	@overload create(data)
	#   Create a new instance which will be immediately persisted to the database. This method is asynchronous
	#   @param data [Object] Initial data for the instance. This data will be merged to the instance as with `Instance.set()`, calling all setters as needed.
	#   @return [Promise<Instance>] A `Promise` whose fate is settled depending on whether the Instance was persisted to the database.
	create: (data) ->
		@_defaultBinding().create(data)

	# Retrieve an instance from the backing store from id or ids.
	#
	# @overload findById(id)
	#   Locate a single instance by id.
	#   @param id [String | Number] The id of the `Instance` as understood by the backing store.
	#   @return [Promise<Instance>] A `Promise` of the `Instance` with the given id, if found. If not found, the `Promise` will resolve with the value `undefined`. The `Promise` is only rejected in the event of a database error.
	#
	# @overload findById(ids)
	#   Locate multiple instances given a list of ids.
	#   @param id [Array<String | Number>] The ids of the `Instance`s as understood by the backing store.
	#   @return [Promise< Array<Instance> >] A `Promise` of an array whose entries correspond to the entries of the `ids` array. In each position, the array will contain the `Instance` with the given id, if found. If not found, the entry will be `undefined`. The `Promise` is only rejected in the event of a database error.
	findById: (id) ->
		@_defaultBinding().findById(id)

	# Retrieve a single instance from the backing store using query options.
	#
	# @param options [Object] Query options. *NB* Not all backends need support all options.
	# @return [Promise<Instance>] A `Promise` of the `Instance` matching the query, if found. If not found, the `Promise` will resolve with the value `undefined`. The `Promise` is only rejected in the event of a database error.
	find: (options) ->
		@_defaultBinding().find(options)

	# Retrieve many instances from the backing store using query options.
	#
	# @param options [Object] Query options. *NB* Not all backends need support all options.
	# @option options [Number] offset Offset for pagination.
	# @option options [Number] limit Limit (number of entries per page) for pagination.
	# @option options [Pagination] pagination A pagination object returned by a previous `findAll` operation. If passed, this operation will retrieve the next page. *NB* Passing a pagination object may override other query options in an attempt to match your query against the one that generated the pagination.
	# @return [Promise<Results>]
	findAll: (options) ->
		@_defaultBinding().findAll(options)


module.exports = Model
