#
# Object representing a declarative request for particular information from a backend.
#
export default class Query

	### istanbul ignore next ###

	# Determine if this query is equal to another query.
	# @param otherQuery [Query] The query to test against.
	isEqual: (otherQuery) ->
		false

	### istanbul ignore next ###

	# Determine if this query is a narrowing of another query.
	# A narrowing is a query that would have a set of results that is a subset of
	# the other query's results, had they been run at the same time.
	isNarrowingOf: (otherQuery) ->
		false

	### istanbul ignore next ###

	# Resume this query from the given Cursor.
	resumeFrom: (cursor) ->

	### istanbul ignore next ###

	# Identify specific instances to be retrieved by id or primary key.
	byId: (id) ->
		if Array.isArray(id) then @ids = id else @ids = [id]
		@
