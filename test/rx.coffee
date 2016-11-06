{ expect } = require 'chai'
ormojo = require '..'
makeCorpus = require './helpers/makeCorpus'
Observable = ormojo.Observable
impl = require 'any-observable/implementation'

RxUtil = ormojo.RxUtil

expectHello = (x) -> expect(x).to.equal('hello')
expectSequence = (seq) ->
	i = 0
	{
		next: (x) -> expect(x).to.equal(seq[i++])
		error: (x) -> throw x
		complete: -> expect(i).to.equal(seq.length)
	}
expectTests = (tests) ->
	i = 0
	{
		next: (x) -> expect(tests[i++](x)).to.equal(true)
		error: (x) -> throw x
		complete: -> expect(i).to.equal(tests.length)
	}

describe 'RxUtil', ->
	it 'should have basic functions', ->
		Observable.of('hello').subscribe({
			next: expectHello
		})
		Observable.of('hello').subscribe(expectHello)

	it 'should inject plain', ->
		inj = new RxUtil.Subject
		RxUtil.merge(null, inj).subscribe(expectHello)
		inj.next('hello')

	it 'should inject stream', ->
		inj = new RxUtil.Subject
		RxUtil.merge(null, inj).subscribe(
			expectSequence( ['hello', 'world'] )
		)
		inj.next('hello'); inj.next('world')

	it 'should mapWithSideEffects', ->
		obj = { method: expectHello }
		RxUtil.mapWithSideEffects(Observable.of('hello'), obj.method, obj).subscribe(expectHello)

describe 'Reducible', ->
	class Payloader extends ormojo.Reducible
		reduce: (action) ->
			@payload = action.payload
			Object.assign({}, action, {payload: action.payload + 1})

	it 'should reduce its own state properly', ->
		pl = new Payloader
		pl.connectAfter(Observable.of({
			type: 'ACTION'
			payload: 5
		}))
		expect(pl.payload).to.equal(5)

	it 'should polymorph action', ->
		pl = new Payloader
		inj = new RxUtil.Subject
		pl.connectAfter(inj).subscribe(expectTests([ (x) -> x.payload is 6 ]))
		inj.next({ type: 'ACTION', payload: 5 })
		expect(pl.payload).to.equal(5)

	it 'should chain', ->
		pl1 = new Payloader
		pl2 = new Payloader
		inj = new RxUtil.Subject
		o1 = pl1.connectAfter(inj)
		o2 = pl2.connectAfter(o1)
		inj.next({ type: 'ACTION', payload: 5 })
		expect(pl2.payload).to.equal(6)

describe 'Hydrator', ->
	it 'should CUD', ->
		{ BWidget: Widget } = makeCorpus()
		inj = new RxUtil.Subject
		hyd = new ormojo.Hydrator({ boundModel: Widget })
		o1 = hyd.connectAfter(inj)
		inj.next({ type: 'CREATE', payload: [ { id: 1, name: 'widget1'}]})
		inst = hyd.getById(1)
		expect(inst.name).to.equal('widget1')
		inj.next({ type: 'UPDATE', payload: [ { id: 1, name: 'widget2'}]})
		expect(inst.name).to.equal('widget2')
		inj.next({ type: 'DELETE', payload: [ 1 ]})
		expect(inst.wasDeleted).to.equal(true)

	it 'should reset, no store', ->
		{ BWidget: Widget } = makeCorpus()
		inj = new RxUtil.Subject
		hyd = new ormojo.Hydrator({ boundModel: Widget })
		o1 = hyd.connectAfter(inj)
		inj.next({ type: 'CREATE', payload: [ { id: 1, name: 'widget1'}]})
		inst = hyd.getById(1)
		expect(inst.name).to.equal('widget1')
		inj.next({ type: 'RESET'})
		expect(inst.wasDeleted).to.equal(true)

	it 'should reset, with store', ->
		class MyStore extends ormojo.Reducible
			constructor: (@storage) ->

			reduce: (action) -> {
				type: action.type
				payload: action.payload
				meta: Object.assign {}, action.meta, {
					store: @
				}
			}

			getById: (id) -> @storage[id]
			forEach: (func) -> func(v, k) for k,v of @storage; undefined


		{ BWidget: Widget } = makeCorpus()
		inj = new RxUtil.Subject
		sto = new MyStore({'1': { id: 1, name: 'widget2'}})
		hyd = new ormojo.Hydrator({ boundModel: Widget })
		o1 = sto.connectAfter(inj)
		o2 = hyd.connectAfter(o1)
		inj.next({ type: 'CREATE', payload: [ { id: 1, name: 'widget1'}]})
		inj.next({ type: 'CREATE', payload: [ { id: 2, name: 'widget2'}]})
		inst = hyd.getById(1)
		inst2 = hyd.getById(2)
		expect(inst.name).to.equal('widget1')
		inj.next({ type: 'RESET'})
		expect(inst.wasDeleted).to.equal(undefined)
		expect(inst.name).to.equal('widget2')
		expect(inst2.wasDeleted).to.equal(true)

describe 'Collector', ->
	it 'should sort', ->
		{ BWidget: Widget } = makeCorpus()
		inj = new RxUtil.Subject
		hyd = new ormojo.Hydrator({ boundModel: Widget })
		sort = new ormojo.Collector
		sort.updater = ->
			@getArray().sort( (a,b) -> if a.name > b.name then 1 else -1 )
		o1 = hyd.connectAfter(inj)
		o2 = sort.connectAfter(o1)
		inj.next({ type: 'CREATE', payload: [ { id: 1, name: 'zed'}]})
		expect(sort.getArray()[0].name).to.equal('zed')
		inj.next({ type: 'CREATE', payload: [ { id: 2, name: 'alpha'}]})
		expect(sort.getArray()[0].name).to.equal('alpha')
		inj.next({ type: 'CREATE', payload: [ { id: 3, name: 'beta'}]})
		expect(sort.getArray()[0].name).to.equal('alpha')
