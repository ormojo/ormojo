{ Backend, BoundModel, createStandardInstanceClassForBoundModel } = require '../..'
cuid = require 'cuid'

class TestBoundModel extends BoundModel
	constructor: (model, backend, bindingOptions) ->
		super
		@storage = {}
		backend.storage[@name] = @storage

	put: (dataValues, shouldCreate = true) ->
		if shouldCreate
			if not dataValues.id then dataValues.id = cuid()
			if dataValues.id of @storage then return @corpus.Promise.reject(new Error('duplicate'))
			@storage[dataValues.id] = {}
		Object.assign(@storage[dataValues.id], dataValues)
		@corpus.Promise.resolve(dataValues)

	# Invoked when an instance wants to save
	save: (instance) ->
		(if instance.isNewRecord
			@put(instance.dataValues, true)
		else
			@put(instance.dataValues, false)
		).then (nextDataValues) ->
			delete instance.isNewRecord
			instance.dataValues = nextDataValues
			instance._clearChanges()
			instance

	# Invoked when an instance wants to destroy
	destroy: (instance) ->
		delete @storage[instance.id]
		@corpus.Promise.resolve()

	_findById: (id) ->
		data = @storage[id]
		if not data
			@corpus.Promise.resolve()
		else
			instance = @createInstance(data)
			@corpus.Promise.resolve(instance)

	_findByIds: (ids) ->
		rst = ids.map( (id) => if not (data = @storage[id]) then undefined else @createInstance(data) )
		@corpus.Promise.resolve(rst)

	findById: (id) ->
		if Array.isArray(id) then @_findByIds(id) else @_findById(id)

class TestBackend extends Backend
	constructor: ->
		super
		@storage = {}

	# Invoked after Corpus.createModel.
	bindModel: (model, bindingOptions) ->
		if not @storage[model.name] then @storage[model.name] = {}
		m = new TestBoundModel(model, @, bindingOptions)
		m.instanceClass = createStandardInstanceClassForBoundModel(m)
		m

module.exports = TestBackend
