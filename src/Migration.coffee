#
# Abstract representation of a database migration.
#
class Migration
	constructor: (@corpus, @backend) ->

	prepare: ->

	#
	# Returns a JSON object representing the migration plan. Backend-specific.
	#
	getMigrationPlan: ->

module.exports = Migration
