export default class Store
  constructor: ({@corpus}) ->


  ### istanbul ignore next ###

  # Get objects from the store corresponding to a Query object.
  # @return [Promise<{cursor: Cursor, data: Object}>]
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
