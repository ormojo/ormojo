# An instance of a `BoundModel`. Typically maps one-to-one onto a single row of a database
# or document of a document-oriented store, though the semantics are backend-dependent.
class Instance
	# Should only be called by `BoundModel`.
	# @private
	constructor: (@boundModel) ->

	# Apply default values to this instance.
	# @private
	__applyDefaults: ->
		for n, field of @boundModel.getFields()
			if (def = field._getDefault(@))?
				@set(field.name, def)
		@

	# Get the raw value from the value store. No getters are called.
	#
	# @abstract
	# @param key [String] Column or object key.
	# @return [Any] The associated value, or undefined.
	getDataValue: (key) ->
		throw new Error('ormojo: `getDataValue` called on abstract instance')

	# Set a raw value in the value store. No setters are called.
	#
	# @abstract
	# @param key [String] Column or object key.
	# @param value [Any] Value to assign. If undefined, the value will be dropped from the instance's store altogether.
	setDataValue: (key, value) ->
		throw new Error('ormojo: `setDataValue` called on abstract instance')

	# Get properties of this instance.
	#
	# @abstract
	# @overload get(key)
	#   Get the value of the given field or property, running all getters.
	#   @param key [String] Name of field or property to get
	#   @return [Any] The result of running the getter on the associated property.
	#
	# @overload get()
	#   Get a JSON object obtained by getting the values of each field.
	#   @return [Object<String, Any>] A hash with keys the name of each field, and associated values the result of running `get` on that field.
	get: (key) ->
		throw new Error('ormojo: `get` called on abstract instance')

	# Set properties of this instance.
	#
	# @abstract
	# @overload set(key, value)
	#   Set the value of the given field or property, running all setters.
	#   @param key [String] Name of field or property to set.
	#   @param value [Any] Value to set.
	#
	# @overload set(values)
	#   Set the values of multiple properties simultaneously, running all setters.
	#   @param values [Object<String, Any>] A hash with keys the name of each field to set, and associated values to be set. `set(key, value)` will be run on each such pair.
	set: (key, value) ->
		throw new Error('ormojo: `set` called on abstract instance')

	# Determine whether changes have been made to this instance since its last
	# synchronization with the backing store.
	#
	# @abstract
	# @overload changed(key)
	#   Determine if the data value with the specified key has changed.
	#   @param key [String] The key to check.
	#   @return [Boolean] `true` or `false` according as the key has changed or not.
	#
	# @overload changed()
	#   Get a list of changed keys, or `false` if no changes.
	#   @return [Array<String> | `false`] An array of key names that have changed, or literal `false` if there are no changes.
	changed: (key) ->
		throw new Error('ormojo: `changed` called on abstract instance')

	# Persist this instance to the backend.
	#
	# @abstract
	# @return [Promise<Instance>] A `Promise` that resolves to this instance after the save operation completes. The Promise rejects on a database error.
	save: ->
		@boundModel.corpus.Promise.reject(new Error('ormojo: `save` called on abstract instance'))

	# Destroy the corresponding instance in the backend.
	#
	# @abstract
	# @return [Promise<bool>] A `Promise` that resolves to `true` if the object is deleted or `false` otherwise. The Promise rejects on a database error.
	destroy: ->
		@boundModel.corpus.Promise.reject(new Error('ormojo: `destroy` called on abstract instance'))

module.exports = Instance
