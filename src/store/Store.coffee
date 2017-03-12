import Query from './Query'

export default class Store
	constructor: ({@corpus, @backend}) ->

	### istanbul ignore next ###

	# Create a Query suitable for this Store.
	# @return [Query]
	createQuery: ->
		new Query


	### istanbul ignore next ###

	# Get objects from the store corresponding to a Query object.
	# @return [Promise<ResultSet>]
	read: (query) ->


	### istanbul ignore next ###

	# Create objects in the store with the given JSON data.
	create: (data) ->


	### istanbul ignore next ###

	# Update objects that already exist, applying the given JSON data.
	update: (data) ->


	### istanbul ignore next ###

	# Update objects where the given datacorresponds to an extant object, otherwise
	# create new objects if no object can be located corresponding to the data.
	upsert: (data) ->


	### istanbul ignore next ###

	# Destroy objects with the given data. Data must be sufficient to identify the object
	# to the backing store.
	delete: (data) ->
