FieldTypes = require './FieldTypes'

module.exports = Object.assign({
	Model: require './Model'
	Corpus: require './Corpus'
	Backend: require './Backend'
	BoundModel: require './BoundModel'
	Field: require './Field'
	Instance: require './Instance'
	Util: require './Util'
	Pagination: require './Pagination'
	createStandardInstanceClassForBoundModel: (require './StandardInstance').createStandardInstanceClassForBoundModel
}, FieldTypes)
