#
# Object representing a declarative request for particular information from a backend.
#
export default class Query
	# Determine if this query is equal to another query.
	# @param otherQuery [Query] The query to test against.
	isEqual: (otherQuery) ->
		false

	# Determine if this query is a narrowing of another query.
	# A narrowing is a query that would have a set of results that is a subset of
	# the other query's results, had they been run at the same time.
	isNarrowingOf: (otherQuery) ->
		false

	# Resume this query from the given Cursor.
	resumeFrom: (cursor) ->
