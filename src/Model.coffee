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

	# Check this model for errors and throw them.
	_checkAndThrow: ->
		if not (@spec?) then throw new Error('Model has no spec')
		if not (@spec.fields?) then throw new Error('Model must define at least one field')
		# Create nonce field objects - these will throw if the field is invalid.
		for k, fieldSpec of @spec.fields
			new Field().fromSpec(k, fieldSpec)
