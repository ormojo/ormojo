# Collection of results from a query that may return multiple results.
# @abstract
class ResultSet
	# The constructor should only be called by backends.
	# @private
	constructor: ->

	# Retrieve the number of results in this set.
	#
	# @return [Number] The count of results.
	getResultCount: -> if @results then @results.length else 0

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
