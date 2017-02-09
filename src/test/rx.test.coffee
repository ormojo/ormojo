{ expect } = require 'chai'
ormojo = require '..'
makeCorpus = require './helpers/makeCorpus'
Observable = ormojo.Observable

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
		RxUtil.merge(inj, null).subscribe(expectHello)
		inj.next('hello')
		sub = RxUtil.merge(inj, inj).subscribe(expectSequence(['hello', 'hello']))
		sub.unsubscribe()

	it 'should inject stream', ->
		inj = new RxUtil.Subject
		RxUtil.merge(null, inj).subscribe(
			expectSequence( ['hello', 'world'] )
		)
		inj.next('hello'); inj.next('world')

describe 'Reducible', ->
	class Payloader extends ormojo.Reducible
		reduce: (action) ->
			@payload = action.payload
			Object.assign({}, action, {payload: action.payload + 1})

		actionFilter: (action) ->
			if action?.type is 'FILTER_ME_OUT' then false else true

	it 'should reduce its own state properly', ->
		pl = new Payloader
		pl.connectAfter(Observable.of({
			type: 'ACTION'
			payload: 5
		}))
		expect(pl.payload).to.equal(5)

	it 'should polymorph and filter action', ->
		pl = new Payloader
		inj = new RxUtil.Subject
		pl.connectAfter(inj)
		inj.next({ type: 'FILTER_ME_OUT', payload: 5})
		expect(pl.payload).to.not.be.ok
		pl.subscribe(expectTests([ (x) -> x.payload is 6 ]))
		inj.next({ type: 'ACTION', payload: 5 })
		expect(pl.payload).to.equal(5)

	it 'should chain', ->
		pl1 = new Payloader
		pl2 = new Payloader
		inj = new RxUtil.Subject
		o1 = pl1.connectAfter(inj)
		o2 = pl2.connectAfter(pl1)
		inj.next({ type: 'ACTION', payload: 5 })
		expect(pl2.payload).to.equal(6)

describe 'ObservableBoundInstance', ->
	it 'should be observable', ->
		{ BWidget: Widget } = makeCorpus()
		Widget.create({name: 'name1', qty: 1})
		.then (widg) ->
			sub1 = Observable.from(widg).subscribe( (next) -> console.log {next} )
			sub2 = Observable.from(widg).subscribe(
				expectTests([
					(x) -> x.name is 'name2'
				])
			)
			widg.name = 'name2'
			sub1.unsubscribe()
			sub2.unsubscribe()

describe 'HydratingCollector', ->
	it 'should CUD', ->
		{ BWidget: Widget } = makeCorpus()
		inj = new RxUtil.Subject
		hyd = new ormojo.HydratingCollector({ hydrator: Widget.hydrator })
		o1 = hyd.connectAfter(inj)
		inj.next({ type: 'CREATE', payload: [ { id: 1, name: 'widget1'}]})
		inst = hyd.getById(1)
		expect(inst.name).to.equal('widget1')
		inj.next({ type: 'UPDATE', payload: [ { id: 1, name: 'widget2'}]})
		expect(inst.name).to.equal('widget2')
		inj.next({ type: 'DELETE', payload: [ { id: 1 } ] })
		expect(inst.wasDeleted).to.equal(true)

	it 'should reset, no store', ->
		{ BWidget: Widget } = makeCorpus()
		inj = new RxUtil.Subject
		hyd = new ormojo.HydratingCollector({ hydrator: Widget.hydrator })
		o1 = hyd.connectAfter(inj)
		inj.next({ type: 'CREATE', payload: [ { id: 1, name: 'widget1'}]})
		inst = hyd.getById(1)
		expect(inst.name).to.equal('widget1')
		inj.next({ type: 'RESET'})
		expect(inst.wasDeleted).to.equal(true)

	it 'should reset, with store', ->
		class MyStore extends ormojo.Reducible
			constructor: (@storage) ->
				super()

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
		sto = new MyStore({
			'1': { id: 1, name: 'widget2'}
			'3': { id: 3, name: 'widget3'}
		})
		hyd = new ormojo.HydratingCollector({ hydrator: Widget.hydrator })
		o1 = sto.connectAfter(inj)
		o2 = hyd.connectAfter(sto)
		inj.next({ type: 'CREATE', payload: [ { id: 1, name: 'widget1'}]})
		inj.next({ type: 'CREATE', payload: [ { id: 2, name: 'widget2'}]})
		inst = hyd.getById(1)
		inst2 = hyd.getById(2)
		expect(inst.name).to.equal('widget1')
		inj.next({ type: 'RESET'})
		expect(inst.wasDeleted).to.equal(undefined)
		expect(inst.name).to.equal('widget2')
		expect(inst2.wasDeleted).to.equal(true)
		expect(hyd.getById(3).name).to.equal('widget3')

describe 'Collector', ->
	it 'should ignore non-CRUD actions', ->
		{ BWidget: Widget } = makeCorpus()
		inj = new RxUtil.Subject
		hyd = new ormojo.HydratingCollector({ hydrator: Widget.hydrator })
		hyd.connectAfter(inj)
		inj.next({ type: 'NUNYA_BIZNESS' })

	it 'should filter', ->
		{ BWidget: Widget } = makeCorpus()
		inj = new RxUtil.Subject
		hyd = new ormojo.HydratingCollector({ hydrator: Widget.hydrator })
		hyd.connectAfter(inj)
		hyd.filter = (entity) -> entity?.name is 'alpha'
		inj.next({ type: 'CREATE', payload: [ { id: 1 } ]})
		expect(hyd.getById(1)).to.not.be.ok
		inj.next({ type: 'CREATE', payload: [ { id: 1, name: 'alpha' } ]})
		expect(hyd.getById(1)).to.be.ok
		inj.next({ type: 'UPDATE', payload: [ { id: 1, name: 'beta' } ]})
		expect(hyd.getById(1)).to.not.be.ok
		inj.next({ type: 'UPDATE', payload: [ { id: 2, name: 'alpha' } ]})
		expect(hyd.getById(2)).to.be.ok
		hyd.forEach (v,k) -> console.log {k, v}

	it 'should sort', ->
		{ BWidget: Widget } = makeCorpus()
		inj = new RxUtil.Subject
		hyd = new ormojo.HydratingCollector({ hydrator: Widget.hydrator })
		sort = new ormojo.Collector
		sort.updater = ->
			@getArray().sort( (a,b) -> if a.name > b.name then 1 else -1 )
		o1 = hyd.connectAfter(inj)
		o2 = sort.connectAfter(hyd)
		inj.next({ type: 'CREATE', payload: [ { id: 1, name: 'zed'}]})
		expect(sort.getArray()[0].name).to.equal('zed')
		inj.next({ type: 'CREATE', payload: [ { id: 2, name: 'alpha'}]})
		expect(sort.getArray()[0].name).to.equal('alpha')
		inj.next({ type: 'CREATE', payload: [ { id: 3, name: 'beta'}]})
		expect(sort.getArray()[0].name).to.equal('alpha')
