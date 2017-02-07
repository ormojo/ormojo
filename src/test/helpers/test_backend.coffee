{ Backend, BoundModel, createStandardInstanceClassForBoundModel, Store, Query, Hydrator } = require '../..'
cuid = require 'cuid'

class TestStore extends Store
	constructor: ->
		super
		@storage = Object.create(null)

	crupsert: (data, isCreate) ->
		@corpus.Promise.resolve().then =>
			for datum in data
				if (not datum?) then throw new Error("invalid create format")
				if not datum.id then datum.id = cuid()
				if isCreate and @storage[datum.id]? then throw new Error("duplicate id")
				@storage[datum.id] = Object.assign({}, @storage[datum.id], datum)

	read: (query) ->
		@corpus.Promise.resolve().then =>
			if not query?.ids? then throw new Error("invalid query format")
			@storage[id] for id in query.ids

	create: (data) ->
		@crupsert(data, true)

	update: (data) ->
		@corpus.Promise.resolve().then =>
			for datum in data
				if not datum?.id? then throw new Error("invalid update format")
				if not @storage[datum.id] then throw new Error("update of nonexistent object")
				@storage[datum.id] = datum
				datum

	upsert: (data) ->
		@crupsert(data, false)

	delete: (data) ->
		@corpus.Promise.resolve().then =>
			for datum in data
				if not datum? then throw new Error("invalid delete format")
				if @storage[datum]?
					delete @storage[datum]
					true
				else
					false

class TestHydrator extends Hydrator
	constructor: -> super

class TestQuery extends Query
	constructor: (id) ->
		if Array.isArray(id) then @ids = id else @ids = [id]

class TestBoundModel extends BoundModel
	constructor: (model, backend, bindingOptions) ->
		super
		@storage = new TestStore({@corpus})
		@hydrator = new TestHydrator({boundModel: @})
		backend.storage[@name] = @storage

	put: (instance, shouldCreate = true) ->
		if shouldCreate
			@storage.create([ @hydrator.willCreate(instance) ])
			.then (createdData) =>
				@hydrator.didCreate(instance, createdData[0])
		else
			@storage.update([ @hydrator.willUpdate(instance) ])
			.then (updatedData) =>
				@hydrator.didUpdate(instance, updatedData[0])

	# Invoked when an instance wants to save
	save: (instance) ->
		if instance.isNewRecord
			@put(instance, true)
		else
			@put(instance, false)

	destroyById: (id) ->
		@storage.delete([id])
		.then (rst) -> rst[0]

	findById: (id) ->
		query = new TestQuery(id)
		@storage.read(query)
		.then (readData) =>
			hydrated = (@hydrator.didRead(null, datum) for datum in readData)
			if Array.isArray(id) then hydrated else hydrated[0]

class TestBackend extends Backend
	constructor: ->
		super
		@storage = {}

	bindModel: (model, bindingOptions) ->
		if not @storage[model.name] then @storage[model.name] = {}
		m = new TestBoundModel(model, @, bindingOptions)
		m.instanceClass = createStandardInstanceClassForBoundModel(m)
		m

module.exports = TestBackend
