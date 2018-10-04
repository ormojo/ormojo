# @ormojo/react-observe

React components that re-render in response to Observables emitting values.

## Components

### <Observe>

Props:

- `source` - an ES7 Observable

- `children` - a render prop whose first parameter will be the most recent emitted value.

- `pure` - Boolean, if true, renders only when the `source` changes or emits a value.
Don't use `pure` if your render prop is a function of props from the enclosing scope!

```jsx
<Observe source={myObservable}>{(value) ->
  <div>{value}</div>
}</Observe>
```

### <ObserveMany>

Props:

- `children` - a render prop whose first parameter will be the most recent emitted value.

- `pure` - Boolean, if true, renders only when the `source` changes or emits a value.
Don't use `pure` if your render prop is a function of props from the enclosing scope!

- All other props are expected to be ES7 Observables, which will be mapped in a key-value
fashion using `combineLatest` and the latest values will be passed to the render prop.

```jsx
<ObserveMany val1={observable1} val2={observable2}>{({val1, val2}) ->
  <div>{val1} {val2}</div>
}</Observe>
```
