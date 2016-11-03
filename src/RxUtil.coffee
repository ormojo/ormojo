import Observable from 'any-observable'
import $$observable from 'symbol-observable'

export class Subject
	constructor: -> @observers = []
	subscribe: (obs) ->
		@observers.push(obs)
		=> @_unsubscribe(obs)
	_unsubscribe: (obs) -> ix = @observers.indexOf(obs); if ix isnt -1 then @observers.splice(ix, 1)

	next: (x) ->
		# Prevent reentrancy
		mutationCopy = @observers.slice()
		observer.next?(x) for observer in mutationCopy
		undefined
	observable: -> this

Object.defineProperty(Subject.prototype, $$observable, {
	value: -> this
	writable: true, configurable: true
})

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

export tap = (obs, tapper) ->
	obs.subscribe({
		next: (x) -> tapper(x); undefined
		error: (err) -> tapper(undefined, err); undefined
		complete: -> tapper(undefined, undefined, true); undefined
	})
	obs
