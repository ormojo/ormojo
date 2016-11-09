import { mapWithSideEffects, Subject } from './RxUtil'

export default class Reducible extends Subject
	reduce: (action) -> action

	next: (action) ->
		if not @actionFilter(action) then return super(action)
		super(@reduce(action))

	connectAfter: (observable) -> observable.subscribe(@)

	filter: (entity) -> true

	actionFilter: (action) -> true
