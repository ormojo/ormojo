Field = require './Field'

class Model
	constructor: (@corpus, @spec) ->
		@name = @spec.name

		@fields = {}; @fieldsList = []
		for k,fspec of @spec.fields
			f = new Field(k, fspec)
			@fields[k] = f; @fieldsList.push(f)

	forBackend: (backendName) ->
		@corpus.getBackend(backendName).bindModel(@)


module.exports = Model
