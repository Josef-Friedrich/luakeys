-- Keep this lua code in sync with README.md and luakeys-doc.tex
local luakeys = require('luakeys')

local def = {
  -- Allow different key names.
  -- or a single string: alias = 'k'
  alias = { 'k', 'ke' },

  -- The key is always included in the result. If no default value is
  -- definied, true is taken as the value.
  always_present = false,

  -- Only values listed in the array table are allowed.
  choices = { 'one', 'two', 'three' },
  data_type = 'string', -- or boolean, integer,
  default = 'value',

  --
  exclusive_group = 'name',

  -- > \g_my_token_list_tl
  l3_tl_set = 'my_token_list',

  -- > \MacroName
  macro = 'MacroName', -- > \MacroName

  -- See http://www.lua.org/manual/5.3/manual.html#6.4.1
  match = '^%d%d%d%d%-%d%d%-%d%d$',

  -- name of the key, can be omitted
  name = 'key',
  opposite_keys = { [true] = 'show', [false] = 'hide' },

  --- A callback function
  ---@tparam any value The current value of key.
  ---@tparam table pre_def The result table before processing the key-value pair definitions.
  ---@tparam table result The current and not yet finalized result table.
  ---@tparam table unknown The current and not yet finalized unknown keys table.
  process = function(value,
    pre_def,
    result,
    unknown)
    return value
  end,
  required = true,
  sub_keys = { key_level_2 = { ... } },
}

local defintions = { key = def }

local options = {
  -- { KEY = 'Value' } -> { key = 'value' }
  case_insensitive_keys = false,

  -- Visit all key-value pairs in the recursive parse tree.
  converter = function(key, value, depth, current_tree, root_tree)
    return key, value
  end,

  -- Automatically convert dimensions into scaled points (1cm -> 1864679).
  -- default: true
  convert_dimensions = false,

  -- Output the results table to the console.
  -- default: false
  debug = true,

  -- A table with some default values. The result table is merged with
  -- this table.
  defaults = { key = 'value' },

  -- Key-value pair defintions.
  definitions = defintions,

  -- Standalone values aka values with numeric keys are converted to
  -- keys holding the value true:
  -- { 'one', 'two', 'three' } -> { one = true, two = true, three = true }
  -- default: false
  naked_as_value = true,

  -- { key = { 'value' } } -> { key = 'value' }
  unpack_single_array_value = false,
}
local result = luakeys.parse('one,two,three', options)
