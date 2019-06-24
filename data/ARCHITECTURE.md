# Use Cases

## Generic Data Access for Libraries

A library should be able to

## API CRUD and Cache on Client-Side

- We should be able to bind declarative models on the client-side to API endpoints and thereby implement CRUD operations.

# Pain Points from Ormojo 1

- DEFEATED BY MINIFICATION - DO NOT RELY ON CLASSNAMES
- Minification mangles class names, but should not defeat our system for hydrating objects...
- Lists vs Arrays is super annoying.
- ALlow assignment of Arrays from regular JS arrays via setter.
- Should implement toJSON() properly.
- Never implemented upcasting/upserialization
- Should be able to serialize a subobject as a JSON field within a containing object and rehydrate properly
- Ignore fields at bind time, serialize time, persistence time ("transients")
- "To SQL Value" function should be implemented at the data-type level
- The Result/ResultSet distinction is annoying (but probably necessary)
- .save, .destroy, etc should reside on model instances, not as tilde-call gimmicks
- Models should know which backend they are bound to. It should be transparent to user code.
- ResultSets should have a .nextPage() or similar which gets the next resultSet
- Cursors should have known/queriable serializability properties. Can I serialize the whole cursor? Offset-only?

# Concepts

## Corpus

The Corpus represents the "global" state of @ormojo/data. Generally speaking
there should be one Corpus per application.

## Model

A Model is a class whose instances are individual items or data entities.

- Models MUST have nonempty string names.
- There MUST be only one Model with a given name per Corpus.
- A Model MAY extend exactly one Model.
- A Model MAY mixin any number of other Models.

## Collection

A Collection is a collection of Model instances. Generally they will all
derive from the same base Model class, though this is not necessary.

(A Collection might correspond with something like a table in MySQL.)

- A Collection can be transient or nontransient.
- A Collection can be either mutable or immutable.
- A Collection MUST belong to exactly one Store, and there MUST be only one Collection of a given name in a Store.
- A Collection MUST belong to exactly one Corpus, and there MUST be only one Collection of a given name in a Corpus.

## Store

A Store is a logical group of Collections and Models, usually corresponding
to a particular physical backend, like a MySQL server.

## StorageClass

A StorageClass is a logical abstraction that informs the engine how a particular
field or model instance is stored.

- How to convert the data to/from JSON
- How to define a property on a containing object
- How to observe the data for changes

## Array and List

- An array field's value is an immutable JavaScript array.
- To update an array field, it must be assigned a new array. Changes to the entries of an array do not register as an update.
- An array field has no pagination and its contents are always serialized in bulk.
- Arrays are fully synchronous.

- A List field's value is an abstract object representing a list stored somewhere.
- A List can only be read through a View.
- Reading and mutating a List is asynchronous.
