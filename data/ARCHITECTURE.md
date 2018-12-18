# Use Cases

## Generic Data Access for Libraries

A library should be able to

## API CRUD and Cache on Client-Side

- We should be able to bind declarative models on the client-side to API endpoints and thereby implement CRUD operations.

# Pain Points from Ormojo 1

- Lists vs Arrays is super annoying.
- Should implement toJSON properly.
- Never implemented upcasting/upserialization

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