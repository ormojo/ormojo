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

	# Determine if this query is equal to another query.
	# @param otherQuery [Query] The query to test against.
	isEqual: (otherQuery) ->
		false

	# Determine if this query is a narrowing of another query.
	# A narrowing is a query that would have a set of results that is a subset of
	# the other query's results, had they been run at the same time.
	isNarrowingOf: (otherQuery) ->
		false
