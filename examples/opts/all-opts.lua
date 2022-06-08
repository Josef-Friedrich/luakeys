require('busted.runner')()
local luakeys = require('luakeys')

-- Update also in README.md
local opts = {
  -- Visit all key-value pairs in the recursive parse tree.
  converter = function(key, value, depth, current, result)
    return key, value
  end,

  -- Automatically convert dimensions into scaled points (1cm -> 1864679).
  convert_dimensions = false,

  -- Print the result table to the console.
  debug = false,

  -- The default value for naked keys (keys without a value).
  default = true,

  -- A table with some default values. The result table is merged with
  -- this table.
  defaults = { key = 'value' },

  -- Key-value pair definitions.
  defs = { key = { default = 'value' } },

  -- lower, snake, upper
  format_keys = { 'snake' },

  hooks = {
    kv_string = function(kv_string)
      return kv_string
    end,

    keys_before_def = function(key, value, depth, current, result)
      return key, value
    end,

    result_before_def = function(result)
    end,

    keys = function(key, value, depth, current, result)
      return key, value
    end,

    result = function(result)
    end,
  },

  -- If true, naked keys are converted to values:
  -- { one = true, two = true, three = true } -> { 'one', 'two', 'three' }
  naked_as_value = false,

  -- Throw no error if there are unknown keys.
  no_error = false,

  -- { key = { 'value' } } -> { key = 'value' }
  unpack = false,
}
local result = luakeys.parse('key', opts)

it('true', function()
  assert.are.same({ key = 'value' }, result)
end)
