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
			@put(instance._getDataValues(), true)
		else
			@put(instance._getDataValues(), false)
		).then (nextDataValues) ->
			instance._setDataValues(nextDataValues)
			instance._clearChanges()
			instance

	destroyById: (id) ->
		if id of @storage
			delete @storage[id]; @corpus.Promise.resolve(true)
		else
			@corpus.Promise.resolve(false)

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

	bindModel: (model, bindingOptions) ->
		if not @storage[model.name] then @storage[model.name] = {}
		m = new TestBoundModel(model, @, bindingOptions)
		m.instanceClass = createStandardInstanceClassForBoundModel(m)
		m

module.exports = TestBackend
