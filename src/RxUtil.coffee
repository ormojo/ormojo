import Observable from 'any-observable'
import $$observable from 'symbol-observable'

export defineObservableSymbol = (proto, value) ->
	Object.defineProperty(proto, $$observable, { writable: true, configurable: true, value })

export class Subject
	constructor: -> @observers = []
	subscribe: (obs) ->
		@observers.push(obs)
		=> @_unsubscribe(obs)
	_unsubscribe: (obs) -> ix = @observers.indexOf(obs); if ix isnt -1 then @observers.splice(ix, 1)

	next: (x) ->
		# Prevent reentrancy from screwing up the iteration
		mutationCopy = @observers.slice()
		observer.next?(x) for observer in mutationCopy
		undefined
	observable: -> this

defineObservableSymbol(Subject.prototype, -> @)

export mapWithSideEffects = (obs, map, mapThis) ->
	rst = new Subject
	baseNext = rst.next
	rst.next = (x) ->
		y = map.call(mapThis, x)
		baseNext.call(this, y)
	obs.subscribe(rst)
	rst

export merge = (obs1, obs2) ->
	if not obs1 then return Observable.from(obs2)
	if not obs2 then return Observable.from(obs1)
	new Observable (observer) ->
		sub1 = Observable.from(obs1).subscribe(observer)
		sub2 = Observable.from(obs2).subscribe(observer)
		-> sub1.unsubscribe?(); sub2.unsubscribe?(); undefined
