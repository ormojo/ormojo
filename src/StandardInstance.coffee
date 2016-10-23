BoundInstance = require './BoundInstance'

# Attaches properties to the instance class prototype so that dot-access to
# declared model fields automatically calls getters as needed.
applyModelPropsToInstanceClass = (boundModel, clazz) ->
	for k,v of boundModel.instanceProps when v
		do (k,v) ->
			Object.defineProperty(clazz.prototype, k, {
				enumerable: true, configurable: true
				get: -> @get(k)
				set: (val) -> @set(k, val)
			})
	undefined

# Creates a standard `BoundInstance` class for the given `BoundModel`
createStandardInstanceClassForBoundModel = (bm) ->
	class StandardInstance extends BoundInstance

	# Create getters and setters
	applyModelPropsToInstanceClass(bm, StandardInstance)

	# Return the instance class
	StandardInstance

module.exports = {
	applyModelPropsToInstanceClass
	createStandardInstanceClassForBoundModel
}
