#
# Object representing a declarative request for particular information from a backend.
#
export default class Query
	# Query constructor.
	# @param spec [Object] Query options specification. *NB:* not all backends will support all options. Please consult backend-specific documentation.
	# @option spec [Number] offset Offset for pagination.
	# @option spec [Number] limit Limit (number of entries per page) for pagination.
	# @option spec [Cursor] cursor A `Cursor` object returned by a previous `BoundModel.findAll` operation. If passed, this operation will retrieve the next page. *NB* Passing a pagination object may override other query options in an attempt to match your query against the one that generated the pagination.
	constructor: (@spec) ->
