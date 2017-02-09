# Collection of results from a query that may return multiple results.
# @abstract
export default class ResultSet
	# The constructor should only be called by backends.
	# @private
	constructor: ->

	### istanbul ignore next ###

	# Determine if this result set is empty.
	#
	# @return [Boolean] `true` if empty.
	isEmpty: -> (@getResultCount() is 0)

	### istanbul ignore next ###

	# Retrieve the number of results in this set.
	#
	# @return [Number] The count of results.
	getResultCount: -> if @results then @results.length else 0

	### istanbul ignore next ###

	# Get the total number of results from the query that produced this `ResultSet`,
	# including results in future pages.
	# Not possible on all backends.
	#
	# @abstract
	# @return [Number] The total number of results.
	getTotalResultCount: ->
		throw new Error('`getTotalResultCount` called on abstract ResultSet')

	### istanbul ignore next ###

	# Retrieve the array of results in this set.
	#
	# @return [Array<Instance>] The collection of results.
	getResults: -> @results or []

	### istanbul ignore next ###

	# Retrieve a cursor representing this set, which can be used to continue a paginated
	# query.
	#
	# @abstract
	# @return [Cursor] A cursor that can be used to get the next ResultSet. A null return indicates no further results are available.
	getCursor: ->
		throw new Error('`getCursor` called on abstract ResultSet')

	### istanbul ignore next ###

	# Determine if the query that generated this `ResultSet` has more results beyond what
	# are available in this set.
	#
	# @return [Boolean] `true` if more results are available.
	hasMore: -> (@getCursor()?)
