{ Backend, BoundModel, createStandardInstanceClassForBoundModel } = require '..'
cuid = require 'cuid'

class TestBackend extends Backend
	constructor: ->
		super()
		@storage = {}

	initialize: ->

	# Invoked after Corpus.createModel.
	bindModel: (model) ->
		if not @storage[model.name] then @storage[model.name] = {}
		new BoundModel(model, @)

	# Invoked when an instance wants to save
	saveInstance: (instance, boundModel) ->
		if instance.isNewRecord
			if not instance.id then instance.id = cuid()
			@storage[boundModel.name][instance.id] = {}
		Object.assign(@storage[boundModel.name][instance.id], instance.dataValues)
		@corpus.promiseResolve(instance)

	# Invoked when an instance wants to destroy
	destroyInstance: (instance, boundModel) ->
		@corpus.promiseResolve().then ->
			delete @storage[boundModel.name][instance.id]

	# Synchronously create an un-persisted instance.
	createRawInstance: (boundModel, dataValues) ->
		if not boundModel.instanceClass
			boundModel.instanceClass = createStandardInstanceClassForBoundModel(boundModel)
		instance = new boundModel.instanceClass(boundModel, dataValues)
		instance

	# Create and save a new instance.
	createInstance: (boundModel, initialData) ->
		instance = @createRawInstance(boundModel)
		instance.isNewRecord = true
		instance.__applyDefaults()
		if initialData isnt undefined
			instance.set(initialData)
			@saveInstance(instance, boundModel)
		else
			instance

	findInstanceById: (boundModel, id) ->
		data = @storage[boundModel.name][id]
		if not data
			@corpus.promiseResolve()
		else
			instance = @createRawInstance(boundModel, data)
			@corpus.promiseResolve(instance)

module.exports = TestBackend
