# Driver that intermediates between the ormojo API and some underlying data layer.
export default class Backend
	# Construct a backend. Generally, initialization work for the backend should not be
	# performed here, but rather in `.initialize`
	#
	# @see Backend#initialize
	constructor: ->

	# @private
	_initialize: (@corpus, @name) -> @initialize()

	### !pragma coverage-skip-next ###

	# Initialize a Backend that has been added to a Corpus.
	initialize: ->

	### !pragma coverage-skip-next ###

	# Invoked when a model is being bound to this backend.
	# Errors thrown from this method indicate that a Model is incompatible with this
	# particular backend.
	#
	# @abstract
	# @param [Model] model The model to bind to this backend.
	bindModel: (model) ->
		throw new Error('Backend: `bindModel` called on abstract backend.')
