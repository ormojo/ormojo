# Abstract representation of a database migration.
# @abstract
export default class Migration
	# Construct a Migration associated with the given `Corpus` and `Backend`.
	constructor: (@corpus, @backend) ->

	# Prepares the migration by assaying the present state of the data store and
	# computing the differences with expected state.
	#
	# @abstract
	# @return [Promise<undefined>] A `Promise` that resolves when preparation is complete.
	prepare: ->

	# Returns a JSON object representing the migration plan. Backend-specific.
	#
	# @abstract
	getMigrationPlan: ->
