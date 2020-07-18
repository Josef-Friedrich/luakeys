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

--- See [lpeg.P](http://www.inf.puc-rio.br/~roberto/lpeg#op-p)
--
-- Like `"literal"` in peg.js.
local Pattern = lpeg.P

--- See [lpeg.R](http://www.inf.puc-rio.br/~roberto/lpeg#op-r)
--
-- Like `[a-z]` in peg.js.
local Range = lpeg.R

--- See [lpeg.S](http://www.inf.puc-rio.br/~roberto/lpeg#op-s)
--
-- Like `[characters]` in peg.js.
local Set = lpeg.S

--- See [lpeg.V](http://www.inf.puc-rio.br/~roberto/lpeg#op-v)
local Variable = lpeg.V

--- See [lpeg.C](http://www.inf.puc-rio.br/~roberto/lpeg#cap-c)
local capture = lpeg.C

--- See [lpeg.Ct](http://www.inf.puc-rio.br/~roberto/lpeg#cap-t)
local capture_table = lpeg.Ct

--- See [lpeg.Cf](http://www.inf.puc-rio.br/~roberto/lpeg#cap-f)
local capture_fold = lpeg.Cf

--- See [lpeg.Cg](http://www.inf.puc-rio.br/~roberto/lpeg#cap-g)
local capture_group = lpeg.Cg

--- See [lpeg.Cg](http://www.inf.puc-rio.br/~roberto/lpeg#cap-cc)
local capture_constant = lpeg.Cc

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
  E06 = "Wrong data type (key: '%s', value: '%s', defined data type: '%s', actual data type: '%s')"
}

--- Prefix all error messages and then throw an error.
--
-- @tparam string message A message text for the error.
local function throw_error(error_code, arg1, arg2, arg3, arg4)
  error('luakeys error (' .. error_code .. '): ' ..
    string.format(error_messages[error_code], arg1, arg2, arg3, arg4))
end

---
-- @see https://stackoverflow.com/a/42062321/10193818
local function print_table(node)
  local cache, stack, output = {},{},{}
  local depth = 1
  local output_str = "{\n"

  while true do
    local size = 0
    for k,v in pairs(node) do
      size = size + 1
    end

    local cur_index = 1
    for k,v in pairs(node) do
      if (cache[node] == nil) or (cur_index >= cache[node]) then
        if (string.find(output_str,"}",output_str:len())) then
          output_str = output_str .. ",\n"
        elseif not (string.find(output_str,"\n",output_str:len())) then
          output_str = output_str .. "\n"
        end

        -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
        table.insert(output,output_str)
        output_str = ""

        local key
        if (type(k) == "number" or type(k) == "boolean") then
          key = "["..tostring(k).."]"
        else
          key = "['"..tostring(k).."']"
        end

        if (type(v) == "number" or type(v) == "boolean") then
          output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
        elseif (type(v) == "table") then
          output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
          table.insert(stack,node)
          table.insert(stack,v)
          cache[node] = cur_index+1
          break
        else
          output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
        end

        if (cur_index == size) then
          output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        else
          output_str = output_str .. ","
        end
      else
        -- close the table
        if (cur_index == size) then
          output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end
      end

      cur_index = cur_index + 1
    end

    if (size == 0) then
      output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
    end

    if (#stack > 0) then
      node = stack[#stack]
      stack[#stack] = nil
      depth = cache[node] == nil and depth + 1 or depth - 1
    else
      break
    end
  end

  -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
  table.insert(output,output_str)
  output_str = table.concat(output)

  print() -- Insert an empty line.
  print(output_str)
end

--- Append patterns as a ordered choice (+) or as a sequence (*).
--
-- @tparam userdata container Container variable
-- @tparam userdata pattern Lpeg pattern to combine
-- @tparam string method 'sequence' (*) or 'choice' (+)
local function append_pattern(method, container, pattern)
  if not container then
    -- start a new choice or sequence.
    container = pattern
  else
    -- append to a existing choice or sequence
    if method == 'choice' then
      container = container + pattern
    elseif method == 'sequence' then
      container = container * pattern
    end
  end
  return container
end

-- Optional whitespace
local white_space = Set(' \t\n\r')^0

--- Match literal string surrounded by whitespace
local WhiteSpacedPattern = function(match)
  return white_space * Pattern(match) * white_space
end

-- Pattern without captures --------------------------------------------

local boolean_true =
  Pattern('true') +
  Pattern('TRUE') +
  Pattern('yes') +
  Pattern('YES')

local boolean_false =
  Pattern('false') +
  Pattern('FALSE') +
  Pattern('no') +
  Pattern('NO')

local number = Pattern({'number',
  number =
    Variable('int') *
    Variable('frac')^-1 *
    Variable('exp')^-1,

  int = Variable('sign')^-1 * (
    Range('19') * Variable('digits') + Variable('digit')
  ),

  sign = Set('+-'),

  digit = Range('09'),

  digits = Variable('digit') * Variable('digits') + Variable('digit'),

  frac = Pattern('.') * Variable('digits'),

  exp = Set('eE') * Variable('sign')^-1 * Variable('digits'),
})

--- Define data type dimension.
--
-- @return Lpeg patterns
local function assemble_dimension()
  local units
  -- https://raw.githubusercontent.com/latex3/lualibs/master/lualibs-util-dim.lua
  for _, dimension_extension in ipairs({'bp', 'cc', 'cm', 'dd', 'em', 'ex', 'in', 'mm', 'nc', 'nd', 'pc', 'pt', 'sp'}) do
    units = append_pattern('choice', units, Pattern(dimension_extension))
  end

  return number * units
end

local dimension = assemble_dimension()

--- Define data type integer.
--
-- @return Lpeg patterns
local function data_type_integer()
  return Range('09')^1
end

--- Define data type integer.
--
-- @return Lpeg patterns
local function assemble_data_type_float()
  -- patt / function
  local digits = Range('09')^1
  local puls_minus = Set('+-')^-1
  return
    puls_minus * digits *
    (Pattern('.') * digits)^-1 *
    (Set('eE') * puls_minus * digits)^-1
end

--- Data type patterens uncaptured
local data_type_patterns = {
  integer = data_type_integer(),
  float = assemble_data_type_float(),
  dimension = assemble_dimension(),
  boolean = boolean_true + boolean_false,
  string = Pattern('"') * (Pattern('\\"') + 1 - Pattern('"'))^0 * Pattern'"',
}

--- Captured data types
-- patt / function
-- Creates a function capture. It calls the given function passing
-- all captures made b nby patt as arguments, or the whole match if
-- patt made no capture. The values returned by the function are the
-- final values of the capture. In particular, if function returns
-- no value, there is no captured value
local captures = {
  boolean =
    boolean_true * capture_constant(true) +
    boolean_false * capture_constant(false),

  number = number / tonumber,
  integer = data_type_patterns.integer / tonumber,
  float = data_type_patterns.float / tonumber,
  dimension = dimension / tex.sp,
  string = Pattern('"') * capture((Pattern('\\"') + 1 - Pattern('"'))^0) * Pattern'"',
}

--- Extended and TeX specialized version of Lua's type function.
--
-- @tparam string string A string to get the type from
--
-- @treturn string The type name like boolean integer
local function get_type(string)
  local parser
  for _, data_type in ipairs({ 'integer', 'float', 'dimension', 'boolean', 'string' }) do
    parser = append_pattern('choice', parser, (
      data_type_patterns[data_type] *
      capture_constant(data_type) *
      Pattern(-1) -- match the whole input string
    ))
  end
  return parser:match(string)
end

--- Build the Lpeg pattern for a single key value pair. The resulting
-- pattern has to capture two strings.
--
-- @tparam string key
-- @tparam table def keys: alias, type
--
-- @treturn userdata Lpeg patterns etc.
local build_key_value_pattern = function(key, def)
  local key_pattern
  local destination_key_name
  local value_pattern

  -- Build the key pattern.
  if def.rename_key then
    destination_key_name = def.rename_key
  else
    destination_key_name = key
  end

  if def.alias then
    -- alias = {'mlines', 'minlines'}
    if type(def.alias) == 'table' then
      key_pattern = Pattern(key)
      for _, value in ipairs(def.alias) do
        key_pattern = key_pattern + Pattern(value)  -- long alias first: 'bool', 'b'
      end
      key_pattern = (key_pattern) * capture_constant(destination_key_name)
    -- alias = 'minlines'
    else
      key_pattern =
        (Pattern(key) + Pattern(def.alias)) *
        capture_constant(destination_key_name)
    end
  else
    if def.rename_key then
      -- old_key=1 -> new_key=1
      key_pattern = Pattern(key) * capture_constant(destination_key_name)
    else
      key_pattern = capture(Pattern(key))
    end
  end

  -- Build the value pattern.
  if def.data_type == 'keyonly' then
    -- key only
    -- show -> show=true
    value_pattern = capture_constant(true)
  elseif def.choices then
    -- Choices
    if type(def.choices) ~= 'table' then
      throw_error('E02', key)
    end
    local choice_pattern
    for _, choice in ipairs(def.choices) do
      choice_pattern = append_pattern('choice', choice_pattern, Pattern(choice))
    end
    value_pattern = WhiteSpacedPattern('=') * capture(choice_pattern)
  elseif def.overwrite_value ~= nil then
    -- overwrite value
    value_pattern = capture_constant(def.overwrite_value)
  else
    -- Match by data type.
    -- key=data_type
    if captures[def.data_type] == nil then
      throw_error('E04', def.data_type)
    end
    value_pattern =
      WhiteSpacedPattern('=') *
      captures[def.data_type]
  end

  return key_pattern * value_pattern
end

--- Build a table with the default values. They are indexed by the key
-- name.
--
-- @tparam table definitions
--
-- @treturn table defaults
local build_defaults_table = function(definitions)
  local defaults = {}
  for key, def in pairs(definitions) do
    if def['default'] ~= nil then
      defaults[key] = def.default
    end
  end
  return defaults
end

--- Build a key value parser using Lpeg.
-- @todo remove and use new function
--
-- @tparam table definitions
--
-- @treturn parser The Lpeg parser
-- @treturn table defaults
local function build_parser(definitions)
  local key_values

  for key, def in pairs(definitions) do
    local key_value = build_key_value_pattern(key, def)
    key_values = append_pattern('choice', key_values, key_value)
  end

  --- Capture unmatched key value pairs to throw errors and warnings.
  --
  -- @tparam string key
  -- @tparam string value
  local capture_unkown_key_value_pair = function(key, value)
    local def = definitions[key]

    if def == nil then
      throw_error('E03', key)
    elseif def.choices then
      throw_error('E05', value, key)
    end

    local value_data_type = get_type(value)
    if def.data_type ~= value_data_type then
      throw_error('E06', key, value, def.data_type, value_data_type)
    end
  end

  -- Catch left over keys or key value pairs for error reportings
  local generic_catcher =
    capture(Range('az', 'AZ', '09')^1) * -- key
    WhiteSpacedPattern('=')^-1 *
    capture(Range('09', 'az', 'AZ')^0) * Pattern(-1) / capture_unkown_key_value_pair

  local keyval_groups = capture_group((key_values + generic_catcher) * WhiteSpacedPattern(',')^-1 )

  -- rawset (table, index, value)
  -- Sets the real value of table[index] to value, without invoking the
  -- __newindex metamethod. table must be a table, index any value
  -- different from nil and NaN, and value any Lua value.
  return capture_fold(capture_table('') * keyval_groups^0, rawset), build_defaults_table(definitions)
end

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
  -- @tparam table table @tparam mixed arg1 @tparam mixed arg2 If arg2
  -- is empty
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

  return Pattern({
    'list',
    value =
      Variable('object') +
      Variable('bool_value') +
      Variable('number_value') +
      Variable('string_value') +
      Variable('string_value_unquoted'),

    bool_value = captures.boolean,

    string_value =
      white_space * Pattern('"') *
      capture((Pattern('\\"') + 1 - Pattern('"'))^0) *
      Pattern('"') * white_space,

    string_value_unquoted =
      white_space *
      capture((1 - Set('{},='))^1) *
      white_space,

    number_value =
      white_space * captures.number * white_space,

    key_word = Range('az', 'AZ', '09'),

    key = white_space * capture(
      Variable('key_word')^1 *
      (Pattern(' ')^1 * Variable('key_word')^1)^0
    ) * white_space,

    value_without_key =
      Variable('number_value') +
      Variable('string_value') +
      Variable('string_value_unquoted'),

    key_value_pair =
      Variable('key') * WhiteSpacedPattern('=') * Variable('value'),

    member_pair =
      capture_group(
        Variable('key_value_pair') +
        Variable('value_without_key')
      ) * WhiteSpacedPattern(',')^-1,

    list = capture_fold(
      capture_table('') * Variable('member_pair')^0,
      add_to_table
    ),

    object =
      WhiteSpacedPattern('{') * Variable('list')  * WhiteSpacedPattern('}')
  })
end

--- Check the definitions table and throw errors.
--
-- @tparam table definitions
local check_definitions = function(definitions)
  if type(definitions) ~= 'table' then
    throw_error('E01')
  end
end

return {
  check_definitions = check_definitions,
  get_type = get_type,
  print_table = print_table,
  build_parser = build_parser,
  generate_parser = generate_parser,
}
