{ expect } = require 'chai'
TestBackend = require './test_backend'
ormojo = require '..'

makeCorpus = ->
	c = new ormojo.Corpus({
		backends: {
			'memory': new TestBackend
		}
		defaultBackend: 'memory'
	})

	c.createModel({
		name: 'widget'
		fields: {
			id: { type: ormojo.STRING }
			name: { type: ormojo.STRING, default: 'nameless' }
			qty: { type: ormojo.INTEGER, default: -> 1 + 1 }
		}
	})

	c


describe 'basic tests: ', ->
	it 'should error on unspecified model', ->
		c = makeCorpus()
		expect(->
			c.createModel()
		).to.throw()

	it 'should error on duplicate model name', ->
		c = makeCorpus()
		expect(->
			c.createModel({name: 'widget', fields: { id: type: ormojo.STRING } })
		).to.throw("createModel: duplicate model name `widget`")

	it 'should create, save, find by id', ->
		c = makeCorpus()
		widget = c.getModel('widget')
		widgetm = widget.forBackend('memory')
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
