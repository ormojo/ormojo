TestBackend = require './test_backend'
ormojo = require '../..'

makeCorpus = ->
	logger = if 'trace' in process.argv then console.log.bind(console) else ->

	corpus = new ormojo.Corpus({
		log: {
			trace: logger
			debug: logger
			info: logger
			warn: logger
			error: logger
			fatal: logger
		}
		backends: {
			'memory': new TestBackend
		}
		defaultBackend: 'memory'
	})

	Widget = corpus.createModel({
		name: 'Widget'
		fields: {
			id: { type: ormojo.STRING }
			flatDefault: { type: ormojo.STRING, defaultValue: 'unnamed' }
			functionalDefault: { type: ormojo.INTEGER, defaultValue: -> 1 + 1 }
			getter: {
				type: ormojo.STRING
				defaultValue: ''
				get: (k) -> @getDataValue(k) + ' getter'
			}
			setter: {
				type: ormojo.STRING
				defaultValue: ''
				set: (k, v) -> @setDataValue(k, v + ' setter')
			}
			getterAndSetter: {
				type: ormojo.STRING
				defaultValue: ''
				get: (k) -> @getDataValue(k) + ' getter'
				set: (k, v) -> @setDataValue(k, v + ' setter')
			}
		}
	})

	{ corpus, Widget }

module.exports = makeCorpus
