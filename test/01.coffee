{ expect } = require 'chai'

describe 'a test: ', ->
	it 'should just work', ->
		true

	it 'should figure out if prototypes work', ->
		class C
			constructor: ->

		Object.defineProperty(C.prototype, 'work', {
			enumerable: false, configurable: false
			get: -> 'works'
			set: (x) ->
		})

		X = new C
		expect(X.work).to.equal('works')
