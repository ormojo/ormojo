class Backend
	constructor: ->

	_initialize: (@corpus) -> @initialize()

	initialize: ->

	# Invoked after Corpus.createModel.
	modelWasAdded: (model) ->


module.exports = Backend
