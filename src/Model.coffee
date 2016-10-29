import Field from './Field'

# Declarative representation of a model.
export default class Model
	# Constructor should only be called by `Corpus.createModel()`.
	# @private
	# @see Corpus#createModel
	constructor: (@corpus, @spec) ->
		@name = @spec.name

	# @private
	_forBackend: (backend, bindingOptions) -> backend.bindModel(@, bindingOptions)

	# Bind this model to the backend in the `Corpus` with the given name.
	#
	# @param backendName [String] Name of a valid backend in the `Corpus` containing this model.
	# @return [BoundModel] A BoundModel tying this model to the given backend.
	forBackend: (backendName, bindingOptions) ->
		@_forBackend(@corpus.getBackend(backendName), bindingOptions)
