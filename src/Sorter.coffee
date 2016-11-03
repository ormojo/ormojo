import Reducible from './Reducible'

export default class Sorter extends Reducible
	constructor: (@sortFunc) ->

	reduce: (action) ->
		hydrator = action.meta?.hydrator
		if not hydrator
			throw new Error('Sorter must be connected after Hydrator')
		@instances = []
		@instances.push(instance) for k,instance of hydrator.instances
		@instances.sort(@sortFunc)
