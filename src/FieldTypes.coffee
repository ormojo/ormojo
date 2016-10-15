module.exports = {
	STRING: 'STRING'
	BOOLEAN: 'BOOLEAN'
	INTEGER: 'INTEGER'
	FLOAT: 'FLOAT'
	OBJECT: 'OBJECT'
	ARRAY: (subtype) -> "ARRAY(#{subtype})"
	ANY: 'ANY'
}
