getDelta = (instance) ->
	changedKeys = instance.changed()
	if not changedKeys then return false
	ret = {}
	ret[k] = instance.dataValues[k] for k in changedKeys
	ret

module.exports = {
	getDelta
}
