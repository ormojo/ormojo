
# Check if a value is primitive.
isPrimitive = (v) ->
	t = typeof(v)
	if (t is 'string') or (t is 'number') or (t is 'boolean') then true else false

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
}
