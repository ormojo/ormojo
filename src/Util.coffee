# Check if a value is primitive.
export isPrimitive = (v) ->
	t = typeof(v)
	if (t is 'string') or (t is 'number') or (t is 'boolean') then true else false

# This is from lodash, its probably okay.
### !pragma coverage-skip-next ###

# Get a value at a deep location in an object.
export get = (object, path) ->
	index = 0; length = path.length
	while object? and index < length
		object = object[path[index++]]
	if (index is length) then object else undefined

# This is from lodash, its probably okay.
### !pragma coverage-skip-next ###

# Set a value at a deep location in an object.
export set = (object, path, val) ->
	index = 0; length = path.length
	while object? and index < (length - 1)
		object = object[path[index++]]
	if object and (index is length - 1)
		object[path[index]] = val
		true
	else
		false

# Get an Object representing the "delta" of this instance from the persisted version.
export getDelta = (instance) ->
	changedKeys = instance.changed()
	if not changedKeys then return false
	ret = {}
	ret[k] = instance.getDataValue(k) for k in changedKeys
	ret
