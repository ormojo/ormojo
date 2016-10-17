reservedWords = require './reservedWords'

class Field
	constructor: ->

	fromSpec: (@name, @spec) ->
		if typeof(@name) isnt 'string' then throw new Error("Invalid field name: must be a string")
		if @name.substr(0, 1) is '_' then throw new Error("Invalid field name `#{@name}`: cannot begin with _")
		if reservedWords[@name] then throw new Error("Invalid field name `#{@name}`: reserved word")
		if not @spec?.type then throw new Error("Invalid field spec for `#{@name}`: must specify a type")
		@

	# Copy constructor.
	fromField: (field) ->
		@fromSpec(field.name, field.spec)
		@

	# Get database column/field name
	getBackendFieldName: -> @name

module.exports = Field
