--- A naive key value parser written with Lpeg to get rid of kvoptions.
--
-- * `patt^0` = `expression *` (peg.js)
-- * `patt^1` = `expression +` (peg.js)
-- * `patt^-1` = `expression ?` (peg.js)
-- * `patt1 * patt2` = `expression1 expression2` (peg.js) -> Sequence
-- * `patt1 + patt2` = `expression1 / expression2` (peg.js) -> Ordered choice
--
-- * [TUGboat article: Parsing complex data formats in LuaTEX with LPEG](https://tug.org/TUGboat/tb40-2/tb125menke-lpeg.pdf)
-- * [Dimension handling in lualibs](https://github.com/lualatex/lualibs/blob/master/lualibs-util-dim.lua)
--
--     local defintions = {
--       -- data types:
--       key_integer = {
--         data_type = 'integer',
--       },
--       -- 1.1 +1.1 -1.1 11e-02
--       key_float = {
--         data_type = 'float',
--       },
--       -- true: true TRUE yes YES 1, false: false FALSE no NO 0
--       key_boolean = {
--         data_type = 'boolean',
--       },
--       key_dimension = {
--         data_type = 'dimension',
--       },
--       keyonly = {
--         data_type = 'keyonly'
--       },
--       -- choices
--       key_choices = {
--         choices = {'one', 'two', 'three'}
--       },
--       -- complementary
--       key_compl = {
--         complementary = {'show', 'hide'}
--       },
--       -- kas=true -> key_alias_single=true
--       key_alias_single = {
--         data_type = 'boolean',
--         alias = 'kas', -- String -> single alias
--       },
--       -- kam=true or k=true -> key_alias_multiple=true
--       key_alias_multiple = {
--         data_type = 'boolean',
--         alias = { 'kam', 'k' }, -- Table -> multiple aliases (long alias first)
--       },
--       key_default = {
--         data_type = 'boolean',
--         default = true
--       },
--       -- old_key=1 -> new_key=1
--       old_key = {
--         data_type = 'integer'
--         rename_key = 'new_key'
--       }
--       -- key_overwrite_value=1 -> key_overwrite_value=2
--       key_overwrite_value = {
--         data_type = 'integer'
--         overwrite_value = 2
--       }
--     }
--
-- @module luakeys

local lpeg = require('lpeg')

--- Generate a PEG parser to be able to parse key value strings
-- like this example:
--
--     show,
--     hide,
--     "string,with,commas",
--     key with spaces = String without quotes,
--     string="String with quotes: ,{}=",
--     number = 2,
--     float = 1.2,
--     list = {one=one,two=two,three=three},
--     nested key = {
--       nested key 2= {
--         key = value,
--       },
--     },
--
-- The string above results in this table:
--
--     { "show", "hide", "string,with,commas",
--       float = 1.2,
--       ["key with spaces"] = "String without quotes",
--       number = 2,
--       string = "String with quotes: ,{}="
--       list = {
--         one = "one",
--         three = "three",
--         two = "two"
--       },
--       ["nested key"] = {
--         ["nested key 2"] = {
--           key = "value"
--         }
--       },
--     }
--
-- @treturn userdata The parser
local function generate_parser()
  -- Optional whitespace
  local white_space = lpeg.S(' \t\n\r')^0

  --- Match literal string surrounded by whitespace
  local WhiteSpacedPattern = function(match)
    return white_space * lpeg.P(match) * white_space
  end

  local boolean_true =
    lpeg.P('true') +
    lpeg.P('TRUE') +
    lpeg.P('yes') +
    lpeg.P('YES')

  local boolean_false =
    lpeg.P('false') +
    lpeg.P('FALSE') +
    lpeg.P('no') +
    lpeg.P('NO')

  local number = lpeg.P({'number',
    number =
      lpeg.V('int') *
      lpeg.V('frac')^-1 *
      lpeg.V('exp')^-1,

    int = lpeg.V('sign')^-1 * (
      lpeg.R('19') * lpeg.V('digits') + lpeg.V('digit')
    ),

    sign = lpeg.S('+-'),
    digit = lpeg.R('09'),
    digits = lpeg.V('digit') * lpeg.V('digits') + lpeg.V('digit'),
    frac = lpeg.P('.') * lpeg.V('digits'),
    exp = lpeg.S('eE') * lpeg.V('sign')^-1 * lpeg.V('digits'),
  })

  --- Add values to a table in a two modes:
  --
  -- # Key value pair
  --
  -- If arg1 and arg2 are not nil, then arg1 is the key and arg2 is the
  -- value of a new table entry.
  --
  -- # Index value
  --
  -- If arg2 is nil, then arg1 is the value and is added as an indexed
  -- (by an integer) value.
  --
  -- @tparam table table
  -- @tparam mixed arg1
  -- @tparam mixed arg2
  --
  -- @treturn table
  local add_to_table = function(table, arg1, arg2)
    if arg2 == nil then
      local index = #table + 1
      return rawset(table, index, arg1)
    else
      return rawset(table, arg1, arg2)
    end
  end

  return lpeg.P({
    'list',
    value =
      lpeg.V('object') +
      lpeg.V('bool_value') +
      lpeg.V('number_value') +
      lpeg.V('string_value') +
      lpeg.V('string_value_unquoted'),

    bool_value =
      boolean_true * lpeg.Cc(true) +
      boolean_false * lpeg.Cc(false),

    string_value =
      white_space * lpeg.P('"') *
      lpeg.C((lpeg.P('\\"') + 1 - lpeg.P('"'))^0) *
      lpeg.P('"') * white_space,

    string_value_unquoted =
      white_space *
      lpeg.C((1 - lpeg.S('{},='))^1) *
      white_space,

    number_value =
      white_space * (number / tonumber) * white_space,

    key_word = lpeg.R('az', 'AZ', '09'),

    key = white_space * lpeg.C(
      lpeg.V('key_word')^1 *
      (lpeg.P(' ')^1 * lpeg.V('key_word')^1)^0
    ) * white_space,

    value_without_key =
      lpeg.V('number_value') +
      lpeg.V('string_value') +
      lpeg.V('string_value_unquoted'),

    key_value_pair =
      lpeg.V('key') * WhiteSpacedPattern('=') * lpeg.V('value'),

    member_pair =
      lpeg.Cg(
        lpeg.V('key_value_pair') +
        lpeg.V('value_without_key')
      ) * WhiteSpacedPattern(',')^-1,

    list = lpeg.Cf(
      lpeg.Ct('') * lpeg.V('member_pair')^0,
      add_to_table
    ),

    object =
      WhiteSpacedPattern('{') * lpeg.V('list')  * WhiteSpacedPattern('}')
  })
end

if not tex then
  tex = {}
end

-- Dummy function for the tests.
tex['sp'] = function (input)
  return 123
end

local error_messages = {
  E01 = "The key-value defintions must be a table.",
  E02 = "Key '%s': choices definition has to be a table.",
  E03 = "Undefined key '%s'.",
  E04 = "Unsupported data type '%s'.",
  E05 = "Not allowed choice '%s' for key '%s'.",
  E06 = "Wrong data type (key: '%s', value: '%s', defined data type: '%s', actual data type: '%s')",
  E07 = "Duplicate usage of the complementary value '%s' that gets stored under the key '%s'.",
}

--- Prefix all error messages and then throw an error.
--
-- @tparam string error_code The error code (for example E01)
-- @tparam mixed arg1 Frist argument to pass to string.format() of the error message.
-- @tparam mixed arg2 Second argument to pass to string.format() of the error message.
-- @tparam mixed arg3 Third argument to pass to string.format() of the error message.
-- @tparam mixed arg4 Fourth argument to pass to string.format() of the error message.
local function throw_error(error_code, arg1, arg2, arg3, arg4)
  error('luakeys error (' .. error_code .. '): ' ..
    string.format(error_messages[error_code], arg1, arg2, arg3, arg4))
end

--- Check the definitions table and throw errors.
--
-- @tparam table definitions
local check_definitions = function(definitions)
  if type(definitions) ~= 'table' then
    throw_error('E01')
  end
end

---
--
-- @tparam table defs The key-value defintions.
-- @tparam table raw A raw key-value input returned by the Lpeg parser.
local normalize_alias_keys = function(defs, raw)
  local function lookup_alias(name)
    for key, _ in pairs(defs) do
      if type(defs[key].alias) == 'table' then
        for _, alias in ipairs(defs[key].alias) do
          if alias == name then
            return key, alias
          end
        end
      elseif type(defs[key].alias) == 'string'  then
        if defs[key].alias == name then
          return key, defs[key].alias
        end
      end
    end
  end

  for key, value in pairs(raw) do
    if defs[key] == nil then
      local new_key = lookup_alias(key)
      if new_key then
        raw[new_key] = value
        raw[key] = nil
      end
    end
  end
  return raw
end

--- Normalize two complementary values into a key and a boolean value.
--
--       defs = {
--         show = {
--           complementary = {'show', 'hide'}
--         },
--       }
--
-- @tparam table defs The key-value defintions.
-- @tparam table raw A raw key-value input returned by the Lpeg parser.
local normalize_complementary_values = function(defs, raw)
  -- To be able to throw errors when duplicate complementary values
  -- are specifed we store the already found complementary keys.
  local duplicates = {}

  local function lookup_value_in_defs(value, defs)
    for key, def in pairs(defs) do
      if type(def.complementary) == 'table' then
        if def.complementary[1] == value then
          return key, true
        elseif def.complementary[2] == value then
          return key, false
        end
      end
    end
  end

  --- We have to reindex the table, so we must call ipairs over and over
  --  again recursively.
  local function normalize_one_value(raw, defs)
    for i, compl_value in ipairs(raw) do
      local key, value = lookup_value_in_defs(compl_value, defs)
      if key ~= nil and value ~= nil then
        if duplicates[key] == true then
          throw_error('E07', compl_value, key)
        end
        table.remove(raw, i)
        raw[key] = value
        duplicates[key] = true
        return normalize_one_value(raw, defs)
      end
    end
    return raw
  end

  return normalize_one_value(raw, defs)
end

return {
  normalize_alias_keys = normalize_alias_keys,
  normalize_complementary_values = normalize_complementary_values,
  check_definitions = check_definitions,
  generate_parser = generate_parser,
}
