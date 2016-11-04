import Reducible from './Reducible'

export default class Sorter extends Reducible
	constructor: (@sortFunc) ->

	reduce: (action) ->
		switch action.type
			when 'CREATE', 'RESET', 'UPDATE', 'DELETE'
				store = action.meta?.store
				if not store
					throw new Error('Sorter must be connected after a Store')
				instances = []
				store.forEach (v,k) -> instances.push(v)
				@instances = instances
				@instances.sort(@sortFunc)
				action

			else
				throw new Error('Sorter expected CRUD action')

	getSorted: ->
		@instances
