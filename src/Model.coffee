Field = require './Field'

class Model
	constructor: (@corpus, @spec) ->
		@name = spec.name

		@fields = {}; @fieldsList = []
		for k,spec of spec.fields
			f = new Field(k, spec)
			@fields[k] = f; @fieldsList.push(f)

module.exports = Model
