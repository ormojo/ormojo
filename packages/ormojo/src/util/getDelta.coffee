# Get an Object representing the "delta" of this instance from the persisted version.
export default getDelta = (instance) ->
	changedKeys = instance.changed()
	if not changedKeys then return false
	ret = {}
	ret[k] = instance.getDataValue(k) for k in changedKeys
	ret
