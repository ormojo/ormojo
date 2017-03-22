import Observable from './Observable'
import theSubject from './Subject'
import $$observable from 'symbol-observable'

export defineObservableSymbol = (proto, value) ->
	Object.defineProperty(proto, $$observable, { writable: true, configurable: true, value })

export Subject = theSubject

export merge = (obs1, obs2) ->
	if not obs1 then return Observable.from(obs2)
	if not obs2 then return Observable.from(obs1)
	new Observable (observer) ->
		sub1 = Observable.from(obs1).subscribe(observer)
		sub2 = Observable.from(obs2).subscribe(observer)
		-> sub1.unsubscribe?(); sub2.unsubscribe?(); undefined

export removeFromList = (list, value) ->
	if (i = list.indexOf(value)) > -1 then list.splice(i, 1)
