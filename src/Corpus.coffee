Model = require './Model'

class Corpus
	constructor: (@config = {}) ->

		#### Export methods to make promises.
		@promiseResolve = @config.promiseResolve or ((x) -> Promise.resolve(x))
		@promiseReject = @config.promiseReject or ((x) -> Promise.reject(x))

		#### Get backends
		@backends = @config.backends or {}
		sz = 0
		for k,v of @backends
			sz++
			if not (v instanceof Backend) then throw new error("Corpus: object at `#{k}` is not a backend")
			v._initialize(@)
		if sz is 0
			throw new Error("Corpus: must register at least one backend")


		@models = {}

	# Create a model within this Corpus with the given spec.
	createModel: (spec) ->
		m = new Model(@, spec)
		@models[m.name] = m
		(v.modelWasAdded(m)) for k,v of @backends
		m


module.exports = Corpus
