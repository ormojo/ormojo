{ expect } = require 'chai'
{ Util } = ormojo = require '..'

describe 'Util tests: ', ->
	it 'isPrimitive', ->
		expect( Util.isPrimitive(true) ).to.be.ok
		expect( Util.isPrimitive(3) ).to.be.ok
		expect( Util.isPrimitive('hello') ).to.be.ok
		expect( Util.isPrimitive({}) ).to.not.be.ok

	it 'get', ->
		obj = { first: { second: { third: 1 } } }
		expect( Util.get(obj, ['first', 'second', 'third'])).to.equal(1)
		expect( Util.get(obj, ['nope', 'never'])).to.not.be.ok

	it 'set', ->
		obj = { first: { second: { third: 1 } } }
		Util.set(obj, ['first', 'second', 'third'], 3)
		expect(obj.first.second.third).to.equal(3)
		expect(Util.set(obj, ['nope', 'never'], 1)).to.not.be.ok
