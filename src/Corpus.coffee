Model = require './Model'

class Corpus
	constructor: (@backends) ->
		sz = 0
		for k,v of @backends
			sz++
			if not (v instanceof Backend) then throw new error("Corpus: object at `#{k}` is not a backend")
		if sz is 0
			throw new Error("Corpus: must register at least one backend")
		@models = {}

	createModel: (spec) ->
		m = new Model(@, spec)
		@models[m.name] = m

module.exports = Corpus
