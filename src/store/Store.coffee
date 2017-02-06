export default class Store
  constructor: ({@corpus}) ->

  # Get objects from the store corresponding to a Query object.
  # @return [Promise<{cursor: Cursor, data: Object}>]
  read: (query) ->

  # Create objects in the store with the given JSON data.
  create: (data) ->

  # Update objects that already exist, applying the given JSON data.
  update: (data) ->

  # Update objects where the given datacorresponds to an extant object, otherwise
  # create new objects if no object can be located corresponding to the data.
  upsert: (data) ->

  # Destroy objects with the given data. Data must be sufficient to identify the object
  # to the backing store.
  delete: (data) ->
