reservedWords = require './reservedWords'

class Field
	constructor: (@name, @spec) ->
		if typeof(@name) isnt 'string' then throw new Error("Invalid field name: must be a string")
		if @name.substr(0, 2) is '__' then throw new Error("Invalid field name `#{@name}`: cannot begin with __")
		if reservedWords[@name] then throw new Error("Invalid field name `#{@name}`: reserved word")
		if not @spec?.type then throw new Error("Invalid field spec for `#{@name}`: must specify a type")

module.exports = Field
