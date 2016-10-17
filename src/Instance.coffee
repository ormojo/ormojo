class Instance
	constructor: (@boundModel) ->

	#
	# Apply default values to this instance.
	#
	__applyDefaults: ->
		for n, field of @boundModel.model.fields
			if (defaulter = field.spec.default)
				if typeof(defaulter) is 'function'
					@set(field.name, defaulter(@))
				else
					@set(field.name, defaulter)
		@

	#
	# Get the raw value of a field. No getters are called.
	#
	getDataValue: (key) ->
		throw new Error('ormojo: `getDataValue` called on abstract instance')

	#
	# Set the raw value of a field.
	#
	setDataValue: (key) ->
		throw new Error('ormojo: `setDataValue` called on abstract instance')

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
	# Determine changes to this instance. If called with a `key`, returns
	# true or false according as the given key has changed. If called with
	# no key, returns all changed values.
	#
	changed: (key) ->
		throw new Error('ormojo: `changed` called on abstract instance')

	#
	# Persist this instance to the backend.
	#
	save: ->
		@boundModel.corpus.Promise.reject(new Error('ormojo: `save` called on abstract instance'))

	#
	# Destroy the corresponding instance in the backend.
	#
	destroy: ->
		@boundModel.corpus.Promise.reject(new Error('ormojo: `destroy` called on abstract instance'))

module.exports = Instance
