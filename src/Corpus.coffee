Model = require './Model'
Backend = require './Backend'

# A collection of models connected to a collection of backends.
class Corpus
	# Create a new `Corpus`
	#
	# @param config [Object] Configuration data.
	# @option config [Object] promise Promise implementation to use internally. By default, uses whatever Promise implementation is installed in the global Promise variable. The object is of the form ```js { reject, resolve, all }```
	# @option config [Object<String, Backend>] backends A hash of named backends available to this Corpus.
	# @option config [Object] log A bunyan-style logger object of the form ```js {trace, debug, info, warn, error, fatal}```. All ormojo logging will be directed through this object. *NB* Trace-level logging is extremely verbose!
	# @option config [String] defaultBackend The name of the backend to use by default when an operation would require a named backend but none is specified.
	constructor: (@config = {}) ->

		# Export methods to make promises.
		@Promise = @config.Promise or {
			reject: (x) -> Promise.reject(x)
			resolve: (x) -> Promise.resolve(x)
			all: (x) -> Promise.all(x)
		}

		# Get backends
		@backends = @config.backends or {}
		sz = 0
		for k,v of @backends
			sz++
			if not (v instanceof Backend) then throw new Error("Corpus: object at `#{k}` is not a backend")
			v._initialize(@, k)
		if sz is 0
			throw new Error("Corpus: must register at least one backend")

		if (not @config.defaultBackend) or (not @backends[@config.defaultBackend])
			throw new Error("Corpus: defaultBackend must be specified and must exist.")

		@models = {}

		# Set up no-op logging functions if needed
		if @config.log
			@log = @config.log
		else
			@log = {
				trace: ->
				debug: ->
				info: ->
				warn: ->
				error: ->
				fatal: ->
			}

	# Create a model within this Corpus with the given spec.
	#
	# @param spec [Object] Specification object for the Model.
	createModel: (spec) ->
		if not spec?.name then throw new Error('createModel: name must be specified')
		if @models[spec.name] then throw new Error("createModel: duplicate model name `#{spec.name}`")

		m = new Model(@, spec)
		@models[m.name] = m
		m

	# Get the `Model` with the given name.
	# @param name [String] Model name
	# @return [Model]
	getModel: (name) -> @models[name]

	# Get the `Backend` with the given name.
	# @param name [String] Backend name
	# @return [Backend]
	getBackend: (name) ->
		if @backends[name] then @backends[name] else throw new Error("No such backend #{name}")

	# Get the default backend for the given model.
	# @param model [Model]
	getDefaultBackendForModel: (model) ->
		backendName = @config.defaultBackends?[model.name] or @config.defaultBackend
		backend = @backends[backendName]
		if not backend
			throw new Error("getDefaultBackendForModel(`#{model.name}`): no such backend `#{backendName}`")
		backend

	# Attach all models to default bindings.
	bindAllModels: ->
		for name, model of @models
			model._defaultBinding()
		undefined


module.exports = Corpus
