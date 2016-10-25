# String field type.
STRING = 'STRING'
# Text field type. On nosql backends this is usually the same as STRING.
TEXT = 'TEXT'
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
	TEXT
	BOOLEAN
	INTEGER
	FLOAT
	OBJECT
	ARRAY
	DATE
	ANY
}
