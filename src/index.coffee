FieldTypes = require './FieldTypes'

module.exports = Object.assign({
	Model: require './Model'
	Corpus: require './Corpus'
	Backend: require './Backend'
	BoundModel: require './BoundModel'
	createStandardInstanceClassForBoundModel: (require './StandardInstance').createStandardInstanceClassForBoundModel
}, FieldTypes)
