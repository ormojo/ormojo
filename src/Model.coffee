Field = require './Field'

class Model
	constructor: (@corpus, @spec) ->
		@name = @spec.name

		@fields = {}; @fieldsList = []
		for k,fspec of @spec.fields
			f = new Field()
			f.fromSpec(k, fspec)
			@fields[k] = f; @fieldsList.push(f)

	_forBackend: (backend) -> backend.bindModel(@)

	forBackend: (backendName) -> @_forBackend(@corpus.getBackend(backendName))

	_defaultBinding: ->
		if @_defaultBound
			@_defaultBound
		else
			@_defaultBound = @_forBackend(@corpus.getDefaultBackendForModel(@))

	#
	# Create a model. If data is provided, asynchronously create a new model with
	# the given data and persist it to the backend. If data is not provided, creates
	# an empty, non-persisted model.
	#
	create: (data) ->
		@_defaultBinding().create(data)

	#
	# Asynchronously locate a model by id. If id is an array, searches for multiple
	# models matching each respective id and returns them in order. If no such
	# model is found, returns undefined.
	#
	findById: (id) ->
		@_defaultBinding().findById(id)

	#
	# Asynchronously locate a SINGLE model. Applies restrictions to limit the result set
	# to one model.
	#
	find: (options) ->
		@_defaultBinding().find(options)

	#
	# findAll: (options) -> Promise< { data: Instance[]?, pagination: Pagination? } >
	# Asynchronously locate multiple models. Provides a Pagination object for continuing
	# retrieval.
	#
	findAll: (options) ->
		@_defaultBinding().findAll(options)


module.exports = Model
