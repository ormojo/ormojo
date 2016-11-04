{ expect } = require 'chai'
ormojo = require '..'
makeCorpus = require './helpers/makeCorpus'

describe 'basic tests: ', ->
	it 'should error on unspecified model', ->
		{ corpus } = makeCorpus()
		expect(->
			corpus.createModel()
		).to.throw()

	it 'should error on duplicate model name', ->
		{ corpus } = makeCorpus()
		expect(->
			corpus.createModel({name: 'Widget', fields: { id: type: ormojo.STRING } })
		).to.throw("createModel: duplicate model name `Widget`")

	it 'should create trivial bound model', ->
		corpus = new ormojo.Corpus({
			backends: {
				test: new ormojo.Backend()
			}
		})
		zz = corpus.createModel({
			name: 'Widget'
			fields: {
				id: { type: ormojo.STRING }
			}
		}).forBackend('test')
		inst = zz.createInstance({id: 1})
		console.log inst
		expect(inst.id).to.equal(1)

	it 'should extend properly', ->
		{ corpus } = makeCorpus()
		bm0 = corpus.getModel('Widget').forBackend('memory')
		expect(bm0.getFields()['extraField']).to.not.be.ok
		bm = corpus.getModel('Widget').forBackend('memory', {
			fields: {
				extraField: { type: ormojo.STRING }
			}
			index: 'esindex'
			type: 'estype'
		})
		expect(bm.getFields()['extraField']).to.be.ok

	it 'should create default values', ->
		{corpus, Widget} = makeCorpus()
		widgetm = Widget.forBackend('memory')
		awidget = widgetm.create()

		expect(awidget.flatDefault).to.equal('unnamed')
		expect(awidget.functionalDefault).to.equal(2)

	it 'should pass defaults through setters', ->
		{corpus, Widget} = makeCorpus()
		widgetm = Widget.forBackend('memory')
		awidget = widgetm.create()

		expect(awidget.getter).to.equal(' getter')
		expect(awidget.setter).to.equal(' setter')
		expect(awidget.getterAndSetter).to.equal(' setter getter')

	it 'should create, save, find by id', ->
		{corpus, Widget} = makeCorpus()
		widgetm = Widget.forBackend('memory')
		awidget = widgetm.create()
		awidget.name = 'whosit'

		testThing = null
		awidget.save().then (thing) ->
			thing
		.then (thing) ->
			testThing = thing
			widgetm.findById(thing.id)
		.then (anotherThing) ->
			expect(anotherThing.get()).to.deep.equal(testThing.get())

	it 'should create by specific id', ->
		{ BWidget: Widget } = makeCorpus()
		awidget = Widget.create()
		awidget.name = '12345'
		awidget.id = 12345

		awidget.save()
		.then ->
			Widget.findById(12345)
		.then (rst) ->
			expect(rst.name).to.equal('12345')

	it 'shouldnt find documents that arent there', ->
		{ BWidget: Widget } = makeCorpus()

		Widget.findById('nothere')
		.then (x) ->
			expect(x).to.equal(undefined)
			Widget.findById(['nothere', 'nowhere'])
		.then (xs) ->
			expect(xs.length).to.equal(2)
			expect(xs[0]).to.equal(undefined)
			expect(xs[1]).to.equal(undefined)

	it 'should save, delete, not find', ->
		{ BWidget: Widget } = makeCorpus()
		id = null
		Widget.create({name: 'whatsit', qty: 1000000})
		.then (widg) ->
			id = widg.id
			widg.destroy()
		.then ->
			Widget.findById(id)
		.then (x) ->
			expect(x).to.equal(undefined)

	it 'should CRUD', ->
		{ BWidget: Widget } = makeCorpus()
		id = null
		Widget.create({name: 'name1', qty: 1})
		.then (widg) ->
			expect(widg.name).to.equal('name1')
			Widget.findById(widg.id)
		.then (widg) ->
			expect(widg.name).to.equal('name1')
			widg.name = 'name2'
			expect(widg.name).to.equal('name2')
			widg.save()
		.then (widg) ->
			Widget.findById(widg.id)
		.then (widg) ->
			expect(widg.name).to.equal('name2')
			id = widg.id
			widg.destroy()
		.then ->
			Widget.findById(id)
		.then (x) ->
			expect(x).to.equal(undefined)

	it 'should diff', ->
		{ BWidget: Widget } = makeCorpus()
		id = null
		Widget.create({name: 'name1', qty: 1})
		.then (widg) ->
			expect(widg.changed()).to.equal(false)
			widg.name = 'name2'
			expect(widg.changed()).to.deep.equal(['name'])
			widg.save()
		.then (widg) ->
			expect(widg.changed()).to.equal(false)
