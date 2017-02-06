# Object representing a pagination of results returned from a backend.
export default class Cursor
	# Only backends should construct Cursors.
	# @private
	# @abstract
	constructor: ->

	### !pragma coverage-skip-next ###

	# Get the total number of results for the query that made this cursor.
	#
	# @abstract
	# @return [Number] The total results.
	getTotalResultCount: ->
		throw new Error('`getTotalResultCount` called on abstract Cursor')

	### !pragma coverage-skip-next ###

	# Get the remaining results not yet fetched for the query that made this Cursor.
	#
	# @Abstract
	# @return [Number] The remaining results.
	getRemainingResultCount: ->
		throw new Error('`getRemainingResultCount` called on abstract Cursor')
