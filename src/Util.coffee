# Check if a value is primitive.
isPrimitive = (v) ->
	t = typeof(v)
	if (t is 'string') or (t is 'number') or (t is 'boolean') then true else false

# Get a value at a deep location in an object.
get = (object, path) ->
	index = 0; length = path.length
	while object? and index < length
		object = object[path[index++]]
	if (index is length) then object else undefined

# Set a value at a deep location in an object.
set = (object, path, val) ->
	index = 0; length = path.length
	while object? and index < (length - 1)
		object = object[path[index++]]
	if object and (index is length - 1)
		object[path[index]] = val
		true
	else
		false

# Get an Object representing the "delta" of this instance from the persisted version.
getDelta = (instance) ->
	changedKeys = instance.changed()
	if not changedKeys then return false
	ret = {}
	ret[k] = instance.dataValues[k] for k in changedKeys
	ret

module.exports = {
	getDelta
	isPrimitive
	set
	get
}
