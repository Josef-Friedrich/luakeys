require('busted.runner')()
local luakeys = require('luakeys')

-- Update also in README.md
local opts = {
  -- { KEY = 'Value' } -> { key = 'value' }
  case_insensitive_keys = false,

  -- Visit all key-value pairs in the recursive parse tree.
  converter = function(key, value, depth, current_tree, root_tree)
    return key, value
  end,

  -- Automatically convert dimensions into scaled points (1cm -> 1864679).
  -- default: false
  convert_dimensions = false,

  -- Print the result table to the console.
  debug = false,

  -- The default value for naked keys (keys without a value).
  default = true,

  -- A table with some default values. The result table is merged with
  -- this table.
  defaults = { key = 'value' },

  -- Key-value pair defintions.
  defs = { key = { default = 'value' } },

  -- If true, naked keys are converted to values:
  -- { one = true, two = true, three = true } -> { 'one', 'two', 'three' }
  naked_as_value = false,

  -- Throw no error if there are unknown keys.
  no_error = false,

  -- { key = { 'value' } } -> { key = 'value' }
  unpack = false,
}
opts.defaults = nil
local result = luakeys.parse('key', opts)

it('true', function ()
  assert.are.same({ key = 'value' }, result)
end)
