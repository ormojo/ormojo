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
	save: (instance, boundModel) ->
		if instance.isNewRecord
			if not instance.id then instance.id = cuid()
			@storage[boundModel.name][instance.id] = {}
			delete instance.isNewRecord
		Object.assign(@storage[boundModel.name][instance.id], instance.dataValues)
		@corpus.Promise.resolve(instance)

	# Invoked when an instance wants to destroy
	destroy: (instance, boundModel) ->
		@corpus.Promise.resolve().then ->
			delete @storage[boundModel.name][instance.id]

	# Synchronously create an un-persisted instance.
	createRawInstance: (boundModel, dataValues) ->
		if not boundModel.instanceClass
			boundModel.instanceClass = createStandardInstanceClassForBoundModel(boundModel)
		instance = new boundModel.instanceClass(boundModel, dataValues)
		instance

	# Create and save a new instance.
	create: (boundModel, initialData) ->
		instance = @createRawInstance(boundModel)
		instance.isNewRecord = true
		instance.__applyDefaults()
		if initialData isnt undefined
			instance.set(initialData)
			@save(instance, boundModel)
		else
			instance

	findById: (boundModel, id) ->
		data = @storage[boundModel.name][id]
		if not data
			@corpus.Promise.resolve()
		else
			instance = @createRawInstance(boundModel, data)
			@corpus.Promise.resolve(instance)

module.exports = TestBackend
