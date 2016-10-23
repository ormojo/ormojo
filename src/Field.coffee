reservedWords = require './reservedWords'

# Declarative representation of a field in a `Model`
class Field
	# Construct a Field.
	constructor: ->

	# Create a field from a specification object.
	#
	# @param name [String] The name of the field. May not begin with `_`.
	# @param spec [Object] An object giving a declarative specification for the field. *NB* Options for fields and their meanings can vary with the backend used!
	# @option spec [FieldType] type The type of the field.
	fromSpec: (@name, @spec) ->
		if typeof(@name) isnt 'string' then throw new Error("Invalid field name: must be a string")
		if @name.substr(0, 1) is '_' then throw new Error("Invalid field name `#{@name}`: cannot begin with _")
		if reservedWords[@name] then throw new Error("Invalid field name `#{@name}`: reserved word")
		if not @spec?.type then throw new Error("Invalid field spec for `#{@name}`: must specify a type")
		@type = @spec.type
		@get = @spec.get
		@set = @spec.set
		@default = @spec.default
		@

	# Copy another field object. Mainly useful for backend implementors deriving
	# a subclass of Field.
	#
	# @param field [Field] The field to copy.
	# @return this [Field] This field.
	fromField: (field) ->
		@fromSpec(field.name, field.spec)
		@

	# Get database column/field name
	getBackendFieldName: -> @name

	# Get the default value of this field for the given Instance.
	# @private
	# @param instance [Instance]
	_getDefault: (instance) ->
		if (@default)?
			if typeof(@default) is 'function' then @default(instance) else @default
		else
			undefined

module.exports = Field
