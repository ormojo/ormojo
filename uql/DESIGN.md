# Universal Query Language

- Based on MongoDB query language
- Queries are plain JSON objects
- Client safe, no injection

## Validation

- Whitelist or blacklist field names
- Whitelist or blacklist operators
- Limit complexity (depth of nesting/breadth of logical chains)


## Examples
Match object with id = 3
```
{
  id: 3
}
```
Match objects with ExpirationDate before now
```
{
  expirationDate: { $lt: Date.now() }
}
```
Match objects with ExpirationDate before now, sort by descending date
```
{
  $filter: {
    expirationDate: { $lt: Date.now() }
  }
  $sort: {
    by: [ ['expirationDate', -1] ]
  }
}
```
Match objects with ExpirationDate before now, fetching a particular page
```
{
  $filter: {
    expirationDate: { $lt: Date.now() }
  }
  $page: {
    limits: [10, 10, 500]
  }
}
```
