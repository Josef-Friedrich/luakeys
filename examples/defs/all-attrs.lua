require('busted.runner')()
local luakeys = require('luakeys')()

-- Update this code example in the README.md
---@type DefinitionCollection
local defs = {
  key = {
    -- Allow different key names.
    -- or a single string: alias = 'k'
    alias = { 'k', 'ke' },

    -- The key is always included in the result. If no default value is
    -- definied, true is taken as the value.
    always_present = false,

    -- Only values listed in the array table are allowed.
    choices = { 'one', 'two', 'three' },

    -- Possible data types:
    -- any, boolean, dimension, integer, number, string, list
    data_type = 'string',

    -- To provide a default value for each naked key individually.
    default = true,

    -- Can serve as a comment.
    description = 'Describe your key-value pair.',

    -- The key belongs to a mutually exclusive group of keys.
    exclusive_group = 'name',

    -- > \MacroName
    macro = 'MacroName', -- > \MacroName

    -- See http://www.lua.org/manual/5.3/manual.html#6.4.1
    match = '^%d%d%d%d%-%d%d%-%d%d$',

    -- The name of the key, can be omitted
    name = 'key',

    -- Convert opposite (naked) keys
    -- into a boolean value and store this boolean under a target key:
    --   show -> opposite_keys = true
    --   hide -> opposite_keys = false
    -- Short form: opposite_keys = { 'show', 'hide' }
    opposite_keys = { [true] = 'show', [false] = 'hide' },

    -- Pick a value by its data type:
    -- 'any', 'string', 'number', 'dimension', 'integer', 'boolean'.
    pick = false, -- ’false’ disables the picking.

    -- A function whose return value is passed to the key.
    process = function(value, input, result, unknown)
      return value
    end,

    -- To enforce that a key must be specified.
    required = false,

    -- To build nested key-value pair definitions.
    sub_keys = { key_level_2 = { } },
  }
}

local parse = luakeys.define(defs)
assert.has_error(function ()
  parse('key=one')
end)
