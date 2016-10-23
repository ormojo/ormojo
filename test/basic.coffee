{ expect } = require 'chai'
ormojo = require '..'
makeCorpus = require './lib/makeCorpus'

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

	it 'should extend properly', ->
		{ corpus } = makeCorpus()
		bm = corpus.getModel('Widget').forBackend('memory', {
			fields: {
				extraField: { type: ormojo.STRING }
			}
			index: 'esindex'
			type: 'estype'
		})
		console.log bm

	it 'should create default values', ->
		{corpus, Widget} = makeCorpus()
		widgetm = Widget.forBackend('memory')
		awidget = widgetm.create()

		expect(awidget.flatDefault).to.equal('unnamed')
		expect(awidget.functionalDefault).to.equal(2)

	it 'should create, save, find by id', ->
		{corpus, Widget} = makeCorpus()
		widgetm = Widget.forBackend('memory')
		awidget = widgetm.create()
		awidget.name = 'whosit'

		testThing = null
		awidget.save().then (thing) ->
			console.log 'saved!', thing.get()
			thing
		.then (thing) ->
			testThing = thing
			widgetm.findById(thing.id)
		.then (anotherThing) ->
			expect(anotherThing.get()).to.deep.equal(testThing.get())
