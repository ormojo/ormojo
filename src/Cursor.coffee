# Object representing a pagination of results returned from a backend.
class Cursor
	# Only backends should construct Cursors.
	# @private
	# @abstract
	constructor: ->

module.exports = Cursor
