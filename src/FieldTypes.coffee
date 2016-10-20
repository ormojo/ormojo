# String field type.
STRING = 'STRING'
# Boolean field type.
BOOLEAN = 'BOOLEAN'
# Integer field type
INTEGER = 'INTEGER'
# Floating-point field type
FLOAT = 'FLOAT'
# Object field type
OBJECT = 'OBJECT'
# Array field type; must specify subtype
ARRAY = (subtype) -> "ARRAY(#{subtype})"
# Date field type
DATE = 'DATE'
# Any field type
ANY = 'ANY'

module.exports = {
	STRING
	BOOLEAN
	INTEGER
	FLOAT
	OBJECT
	ARRAY
	DATE
	ANY
}
