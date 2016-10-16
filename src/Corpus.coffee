Model = require './Model'
Backend = require './Backend'

class Corpus
	constructor: (@config = {}) ->

		#### Export methods to make promises.
		@Promise = @config.Promise or {
			reject: (x) -> Promise.reject(x)
			resolve: (x) -> Promise.resolve(x)
			all: (x) -> Promise.all(x)
		}

		#### Get backends
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

		#### Set up no-op logging functions if needed
		if @config.log
			@log = config.log
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
	createModel: (spec) ->
		if not spec?.name then throw new Error('createModel: name must be specified')
		if @models[spec.name] then throw new Error("createModel: duplicate model name `#{spec.name}`")

		m = new Model(@, spec)
		@models[m.name] = m
		m

	getModel: (name) -> @models[name]

	getBackend: (name) ->
		if @backends[name] then @backends[name] else throw new Error("No such backend #{name}")

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
