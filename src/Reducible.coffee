import { mapWithSideEffects } from './RxUtil'

export default class Reducible
	reduce: (action) -> action
	connectAfter: (observable) ->
		mapWithSideEffects(observable, @reduce, @)
