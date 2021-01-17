--- A key-value parser written with Lpeg.
--
-- Explanations of some LPeg notation forms:
--
-- * `patt ^ 0` = `expression *`
-- * `patt ^ 1` = `expression +`
-- * `patt ^ -1` = `expression ?`
-- * `patt1 * patt2` = `expression1 expression2`: Sequence
-- * `patt1 + patt2` = `expression1 / expression2`: Ordered choice
--
-- * [TUGboat article: Parsing complex data formats in LuaTEX with LPEG](https://tug.org/TUGboat/tb40-2/tb125menke-lpeg.pdf)
--
-- @module luakeys

local lpeg = require('lpeg')

if not tex then
  tex = {}

  -- Dummy function for the tests.
  tex['sp'] = function (input)
    return 1234567
  end
end

--- Generate the PEG parser using Lpeg.
--
-- @treturn userdata The parser
local function generate_parser(options)
  -- Optional whitespace
  local white_space = lpeg.S(' \t\n\r')^0

  --- Match literal string surrounded by whitespace
  local ws = function(match)
    return white_space * lpeg.P(match) * white_space
  end

  local boolean_true =
    lpeg.P('true') +
    lpeg.P('TRUE') +
    lpeg.P('True')

  local boolean_false =
    lpeg.P('false') +
    lpeg.P('FALSE') +
    lpeg.P('False')

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

  --- Define data type dimension.
  --
  -- @return Lpeg patterns
  local function build_dimension_pattern()
    local sign = lpeg.S('-+')
    local integer = lpeg.R('09')^1
    local tex_number = (integer^1 * (lpeg.P('.') * integer^1)^0) + (lpeg.P('.') * integer^1)
    local unit
    -- https://raw.githubusercontent.com/latex3/lualibs/master/lualibs-util-dim.lua
    for _, dimension_extension in ipairs({'bp', 'cc', 'cm', 'dd', 'em', 'ex', 'in', 'mm', 'nc', 'nd', 'pc', 'pt', 'sp'}) do
      if unit then
        unit = unit + lpeg.P(dimension_extension)
      else
        unit = lpeg.P(dimension_extension)
      end
    end

    local dimension = (sign^0 * tex_number * unit)

    if options.convert_dimensions then
      return dimension / tex.sp
    else
      return lpeg.C(dimension)
    end
  end

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

    list = lpeg.Cf(
      lpeg.Ct('') * lpeg.V('list_item')^0,
      add_to_table
    ),

    list_container =
      ws('{') * lpeg.V('list') * ws('}'),

    list_item =
      lpeg.Cg(
        lpeg.V('key_value_pair') +
        lpeg.V('value')
      ) * ws(',')^-1,

    key_value_pair =
      (lpeg.V('key') * ws('=')) * (lpeg.V('list_container') + lpeg.V('value')),

    -- ./ for tikz style keys
    key_word = lpeg.R('az', 'AZ', '09', './'),

    key = white_space * lpeg.C(
      lpeg.V('key_word')^1 *
      (lpeg.P(' ')^1 * lpeg.V('key_word')^1)^0
    ) * white_space,

    value =
      lpeg.V('boolean') +
      lpeg.V('dimension') +
      lpeg.V('number') +
      lpeg.V('string_quoted') +
      lpeg.V('string_unquoted'),

    boolean =
      boolean_true * lpeg.Cc(true) +
      boolean_false * lpeg.Cc(false),

    dimension = build_dimension_pattern(),

    string_quoted =
      white_space * lpeg.P('"') *
      lpeg.C((lpeg.P('\\"') + 1 - lpeg.P('"'))^0) *
      lpeg.P('"') * white_space,

    string_unquoted =
      white_space *
      lpeg.C((1 - lpeg.S('{},='))^1) *
      white_space,

    number =
      white_space * (number / tonumber) * white_space,

  })
end

local function trim(input_string)
  return input_string:gsub('^%s*(.-)%s*$', '%1')
end

--- Get the size of an array like table `{ 'one', 'two', 'three' }` = 3.
--
-- @tparam table value A table or any input.
--
-- @treturn number The size of the array like table. 0 if the input is
-- no table or the table is empty.
local function get_array_size(value)
  local count = 0
  if type(value) == 'table' then
    for _ in ipairs(value) do count = count + 1 end
  end
  return count
end

--- Get the size of a table `{ one = 'one', 'two', 'three' }` = 3.
--
-- @tparam table value A table or any input.
--
-- @treturn number The size of the array like table. 0 if the input is
-- no table or the table is empty.
local function get_table_size(value)
  local count = 0
  if type(value) == 'table' then
    for _ in pairs(value) do count = count + 1 end
  end
  return count
end

--- Unpack a single valued array table like `{ 'one' }` into `one` or
-- `{ 1 }` into `into`.
--
-- @treturn If the value is a array like table with one non table typed
-- value in it, the unpacked value, else the unchanged input.
local function unpack_single_valued_array_table(value)
  if
    type(value) == 'table' and
    get_array_size(value) == 1 and
    get_table_size(value) == 1 and
    type(value[1]) ~= 'table'
  then
    return value[1]
  end
  return value
end

--- This normalization tasks are performed on the raw input table
-- coming directly from the PEG parser:
--
-- 1. Trim all strings: ` text \n` into `text`
-- 2. Unpack all single valued array like tables: `{ 'text' }`
--    into `text`
--
-- @tparam table raw The raw input table coming directly from the PEG
--   parser
--
-- @treturn table A normalized table ready for the outside world.
local function normalize(raw, options)
  local function normalize_recursive(raw, result, options)
    for key, value in pairs(raw) do
      if options.unpack_single_array_values then
        value = unpack_single_valued_array_table(value)
      end
      if type(value) == 'table' then
        result[key] = normalize_recursive(value, {}, options)
      elseif type(value) == 'string' then
        result[key] = trim(value)
      else
        result[key] = value
      end
    end
    return result
  end
  return normalize_recursive(raw, {}, options)
end

--- The function `stringify(tbl, for_tex)` converts a Lua table into a
--   printable string. Stringify a table means to convert the table into
--   a string. This function is used to realize the `print` function.
--   `stringify(tbl, true)` (`for_tex = true`) generates a string which
--   can be embeded into TeX documents. The macro `\luakeysdebug{}` uses
--   this option. `stringify(tbl, false)` or `stringify(tbl)` generate a
--   string suitable for the terminal.
--
-- @tparam table input A table to stringify.
--
-- @tparam boolean for_tex Stringify the table into a text string that
--   can be embeded inside a TeX document via tex.print(). Curly braces
--   and whites spaces are escaped.
--
-- https://stackoverflow.com/a/54593224/10193818
local function stringify(input, for_tex)
  local line_break, start_bracket, end_bracket, indent

  if for_tex then
    line_break = '\\par'
    start_bracket = '\\{'
    end_bracket = '\\}'
    indent = '\\ \\ '
  else
    line_break = '\n'
    start_bracket = '{'
    end_bracket = '}'
    indent = '  '
  end

  local function stringify_inner(input, depth)
    local output = {}
    depth = depth or 0;

    local function add(depth, text)
      table.insert(output, string.rep(indent, depth) .. text)
    end

    for key, value in pairs(input) do
      if (key and type(key) == 'number' or type(key) == 'string') then
        key = string.format('[\'%s\']', key);

        if (type(value) == 'table') then
          if (next(value)) then
            add(depth, key .. ' = ' .. start_bracket);
            add(0, stringify_inner(value, depth + 1, for_tex));
            add(depth, end_bracket .. ',');
          else
            add(depth, key .. ' = ' .. start_bracket .. end_bracket .. ',');
          end
        else
          if (type(value) == 'string') then
            value = string.format('\'%s\'', value);
          else
            value = tostring(value);
          end

          add(depth, key .. ' = ' .. value .. ',');
        end
      end
    end

    return table.concat(output, line_break)
  end

  return start_bracket .. line_break .. stringify_inner(input, 1) .. line_break .. end_bracket
end

--- For the LaTeX version of the macro
--  `\luakeysdebug[options]{kv-string}`.
--
-- @tparam table options_raw Options in a raw format. The table may be
-- empty or some keys are not set.
--
-- @treturn table
local function normalize_parse_options (options_raw)
  if options_raw == nil then
    options_raw = {}
  end
  local options = {}

  if options_raw['unpack single array values'] ~= nil then
    options['unpack_single_array_values'] = options_raw['unpack single array values']
  end

  if options_raw['convert dimensions'] ~= nil then
    options['convert_dimensions'] = options_raw['convert dimensions']
  end

  if options.convert_dimensions == nil then
    options.convert_dimensions = true
  end

  if options.unpack_single_array_values == nil then
    options.unpack_single_array_values = true
  end

  return options
end

return {
  stringify = stringify,

  --- Parse a LaTeX/TeX style key-value string into a Lua table. With
  -- this function you should be able to parse key-value strings like
  -- this example:
  --
  --     show,
  --     hide,
  --     key with spaces = String without quotes,
  --     string="String with double quotes: ,{}=",
  --     dimension = 1cm,
  --     number = -1.2,
  --     list = {one,two,three},
  --     key value list = {one=one,two=two,three=three},
  --     nested key = {
  --       nested key 2= {
  --         key = value,
  --       },
  --     },
  --
  -- The string above results in this Lua table:
  --
  --     {
  --       'show',
  --       'hide',
  --       ['key with spaces'] = 'String without quotes',
  --       string = 'String with double quotes: ,{}=',
  --       dimension = 1864679,
  --       number = -1.2,
  --       list = {'one', 'two', 'three'},
  --       key value list = {
  --         one = 'one',
  --         three = 'three',
  --         two = 'two'
  --       },
  --       ['nested key'] = {
  --         ['nested key 2'] = {
  --           key = 'value'
  --         }
  --       },
  --     }

  -- @tparam string kv_string A string in the TeX/LaTeX style key-value
  --   format as described above.
  --
  -- @tparam table options A table containing
  -- settings: `convert_dimensions` `unpack_single_array_values`
  --
  -- @treturn table A hopefully properly parsed table you can do
  -- something useful with.
  parse = function (kv_string, options)
    if kv_string == nil then
      return {}
    end
    options = normalize_parse_options()

    local parser = generate_parser(options)
    return normalize(parser:match(kv_string), options)
  end,

  --- The function `render(tbl)` reverses the function
  --  `parse(kv_string)`. It takes a Lua table and converts this table
  --  into a key-value string. The resulting string usually has a
  --  different order as the input table. In Lua only tables with
  --  1-based consecutive integer keys (a.k.a. array tables) can be
  --  parsed in order.
  --
  -- @tparam table tbl A table to be converted into a key-value string.
  --
  -- @treturn string A key-value string that can be passed to a TeX
  -- macro.
  render = function (tbl)
    local function render_inner(tbl)
      local output = {}
      local function add(text)
        table.insert(output, text)
      end
      for key, value in pairs(tbl) do
        if (key and type(key) == 'string') then
          if (type(value) == 'table') then
            if (next(value)) then
              add(key .. '={');
              add(render_inner(value));
              add('},');
            else
              add(key .. '={},');
            end
          else
            add(key .. '=' .. tostring(value) .. ',');
          end
        else
          add(tostring(value) .. ',')
        end
      end
      return table.concat(output)
    end
    return render_inner(tbl)
  end,

  --- The function `print(tbl)` pretty prints a Lua table to standard
  --   output (stdout). It is a utility function that can be used to
  --   debug and inspect the resulting Lua table of the function
  --   `parse`. You have to compile your TeX document in a console to
  --   see the terminal output.
  --
  -- @tparam table tbl A table to be printed to standard output for
  -- debugging purposes.
  print = function(tbl)
    print(stringify(tbl, false))
  end,

}
