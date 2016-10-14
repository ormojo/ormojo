Field = require './Field'

class Model
	constructor: (@corpus, @spec) ->
		@name = @spec.name

		@fields = {}; @fieldsList = []
		for k,fspec of @spec.fields
			f = new Field(k, fspec)
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
	# asynchronously locate a model by id.
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
