# Collection of results from a query that may return multiple results.
# @abstract
class ResultSet
	# The constructor should only be called by backends.
	# @private
	constructor: ->

	# Determine if this result set is empty.
	#
	# @return [Boolean] `true` if empty.
	isEmpty: -> (@getResultCount() is 0)

	# Retrieve the number of results in this set.
	#
	# @return [Number] The count of results.
	getResultCount: -> if @results then @results.length else 0

	# Get the total number of results from the query that produced this `ResultSet`,
	# including results in future pages.
	# Not possible on all backends.
	#
	# @abstract
	# @return [Number] The total number of results.
	getTotalResultCount: ->
		throw new Error('`getTotalResultCount` called on abstract ResultSet')

	# Retrieve the array of results in this set.
	#
	# @return [Array<Instance>] The collection of results.
	getResults: -> @results or []

	# Retrieve a cursor representing this set, which can be used to continue a paginated
	# query.
	#
	# @abstract
	# @return [Cursor] A cursor that can be used to get the next ResultSet. A null return indicates no further results are available.
	getCursor: ->
		throw new Error('`getCursor` called on abstract ResultSet')

module.exports = ResultSet
