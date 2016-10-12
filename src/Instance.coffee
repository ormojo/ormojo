class Instance
	constructor: (@boundModel) ->

	#
	# Get the value of a field on this instance by key.
	# If the key is not specified, converts the instance to a plain object.
	#
	get: (key) ->
		throw new Error('ormojo: `get` called on abstract instance')

	#
	# Set the value of a field on this instance.
	#
	set: (key, value) ->
		throw new Error('ormojo: `set` called on abstract instance')

	#
	# Persist this instance to the backend.
	#
	save: ->
		@getCorpus().promiseReject(new Error('ormojo: `save` called on abstract instance'))
