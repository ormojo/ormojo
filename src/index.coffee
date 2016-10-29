import Model from './Model'
import Corpus from './Corpus'
import Backend from './Backend'
import BoundModel from './BoundModel'
import Field from './Field'
import Instance from './Instance'
import * as Util from './Util'
import Cursor from './Cursor'
import Migration from './Migration'
import ResultSet from './ResultSet'
import Query from './Query'
import { createStandardInstanceClassForBoundModel } from './StandardInstance'

# String field type.
export STRING = 'STRING'
# Text field type. On nosql backends this is usually the same as STRING.
export TEXT = 'TEXT'
# Boolean field type.
export BOOLEAN = 'BOOLEAN'
# Integer field type
export INTEGER = 'INTEGER'
# Floating-point field type
export FLOAT = 'FLOAT'
# Object field type
export OBJECT = 'OBJECT'
# Array field type; must specify subtype
export ARRAY = (subtype) -> "ARRAY(#{subtype})"
# Date field type
export DATE = 'DATE'
# Any field type
export ANY = 'ANY'

export {
	Model, Corpus, Backend, BoundModel
	Field, Instance, Util, Cursor
	Migration, ResultSet, Query
	createStandardInstanceClassForBoundModel
}
