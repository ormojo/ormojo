import Model from './Model'
import Corpus from './Corpus'
import Backend from './Backend'
import BoundModel from './BoundModel'
import Field from './Field'
import Instance from './Instance'
import BoundInstance from './BoundInstance'
import Migration from './Migration'
import ResultSet from './ResultSet'
import { createStandardInstanceClassForBoundModel, applyModelPropsToInstanceClass } from './StandardInstance'

import Query from './store/Query'
import Cursor from './store/Cursor'
import Hydrator from './store/Hydrator'
import Store from './store/Store'

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
	Field, Instance, BoundInstance,
	Migration, ResultSet
	createStandardInstanceClassForBoundModel, applyModelPropsToInstanceClass
	Query, Cursor, Hydrator, Store
}

export default ormojo = {
	Model, Corpus, Backend, BoundModel
	Field, Instance, BoundInstance,
	Migration, ResultSet
	createStandardInstanceClassForBoundModel, applyModelPropsToInstanceClass
	Query, Cursor, Hydrator, Store
	STRING, TEXT, BOOLEAN, INTEGER, FLOAT, OBJECT, ARRAY, DATE, ANY
}
