--- A key value parser written with Lpeg.
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
-- @module luakeys

local lpeg = require('lpeg')

if not tex then
  tex = {}

  -- Dummy function for the tests.
  tex['sp'] = function (input)
    return 1234567
  end
end

local settings = {
  convert_dimensions = true,
  unpack_single_array_value = true,
  debug_output_target = 'tex',
}

--- Generate the PEG parser using Lpeg.
--
-- @treturn userdata The parser
local function generate_parser()
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

    if settings.convert_dimensions then
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
    value =
      lpeg.V('object') +
      lpeg.V('bool_value') +
      lpeg.V('dimension_value') +
      lpeg.V('number_value') +
      -- lpeg.V('string_single_quoted') +
      lpeg.V('string_value') +
      lpeg.V('string_value_unquoted'),

    bool_value =
      boolean_true * lpeg.Cc(true) +
      boolean_false * lpeg.Cc(false),

    dimension_value = build_dimension_pattern(),

    string_value =
      white_space * lpeg.P('"') *
      lpeg.C((lpeg.P('\\"') + 1 - lpeg.P('"'))^0) *
      lpeg.P('"') * white_space,

    -- string_single_quoted =
    --   white_space * lpeg.P('\'') *
    --   lpeg.C((lpeg.P('\\\'') + 1 - lpeg.P('\''))^0) *
    --   lpeg.P('\'') * white_space,

    string_value_unquoted =
      white_space *
      lpeg.C((1 - lpeg.S('{},='))^1) *
      white_space,

    number_value =
      white_space * (number / tonumber) * white_space,

    -- ./ for tikz style keys
    key_word = lpeg.R('az', 'AZ', '09', './'),

    key = white_space * lpeg.C(
      lpeg.V('key_word')^1 *
      (lpeg.P(' ')^1 * lpeg.V('key_word')^1)^0
    ) * white_space,

    value_without_key =
      lpeg.V('dimension_value') +
      lpeg.V('number_value') +
      lpeg.V('string_value') +
      lpeg.V('string_value_unquoted'),

    key_value_pair =
      lpeg.V('key') * ws('=') * lpeg.V('value'),

    member_pair =
      lpeg.Cg(
        lpeg.V('key_value_pair') +
        lpeg.V('value_without_key')
      ) * ws(',')^-1,

    list = lpeg.Cf(
      lpeg.Ct('') * lpeg.V('member_pair')^0,
      add_to_table
    ),

    object =
      ws('{') * lpeg.V('list') * ws('}')
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
local function normalize(raw)
  local function normalize_recursive(raw, result)
    for key, value in pairs(raw) do
      if settings.unpack_single_array_value then
        value = unpack_single_valued_array_table(value)
      end
      if type(value) == 'table' then
        result[key] = normalize_recursive(value, {})
      elseif type(value) == 'string' then
        result[key] = trim(value)
      else
        result[key] = value
      end
    end
    return result
  end
  return normalize_recursive(raw, {})
end

--- Pretty print a table.
--
-- @tparam value A table to print.
--
-- see https://stackoverflow.com/a/42062321/10193818
local function stringify_table (input, for_tex)
  local cache, stack, output = {}, {}, {}
  local depth = 1
  local line_break, start_bracket, end_bracket, indent
  if for_tex then
    line_break = '\\par'
    start_bracket = '$\\{$'
    end_bracket = '$\\}$'
    indent = '\\ \\ '
  else
    line_break = '\n'
    start_bracket = '{'
    end_bracket = '}'
    indent = '  '
  end

  local output_str = start_bracket

  while true do
    local size = 0
    for k,v in pairs(input) do
      size = size + 1
    end

    local cur_index = 1
    for k,v in pairs(input) do
      if (cache[input] == nil) or (cur_index >= cache[input]) then
        if (string.find(output_str, end_bracket, output_str:len())) then
          output_str = output_str .. "," .. line_break
        elseif not (string.find(output_str, line_break, output_str:len())) then
          output_str = output_str .. line_break
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
          output_str = output_str .. string.rep(indent, depth) .. key .. " = " .. tostring(v)
        elseif (type(v) == "table") then
          output_str = output_str .. string.rep(indent, depth) .. key .. " = " .. start_bracket .. line_break
          table.insert(stack, input)
          table.insert(stack, v)
          cache[input] = cur_index + 1
          break
        else
          output_str = output_str .. string.rep(indent, depth) .. key .. " = '" .. tostring(v) .. "'"
        end

        if (cur_index == size) then
          output_str = output_str .. line_break .. string.rep(indent, depth - 1) .. end_bracket
        else
          output_str = output_str .. ","
        end
      else
        -- close the table
        if (cur_index == size) then
          output_str = output_str .. line_break .. string.rep(indent, depth - 1) .. end_bracket
        end
      end

      cur_index = cur_index + 1
    end

    if (size == 0) then
      output_str = output_str .. line_break .. string.rep(indent, depth - 1) .. end_bracket
    end

    if (#stack > 0) then
      input = stack[#stack]
      stack[#stack] = nil
      depth = cache[input] == nil and depth + 1 or depth - 1
    else
      break
    end
  end

  -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
  table.insert(output, output_str)
  output_str = table.concat(output)
  return output_str
end

---A helper function to print a table's contents.
-- https://stackoverflow.com/a/54593224/10193818
---@param tbl table @The table to print.
---@param depth number @The depth of sub-tables to traverse through and print.
---@param n number @Do NOT manually set this. This controls formatting through recursion.
local function stringify_table_ng(tbl, depth, for_tex)
  local output = {}
  depth = depth or 0;

  local line_break, start_bracket, end_bracket, indent

  if for_tex then
    line_break = '\\par'
    start_bracket = '$\\{$'
    end_bracket = '$\\}$'
    indent = '\\ \\ '
  else
    line_break = '\n'
    start_bracket = '{'
    end_bracket = '}'
    indent = '  '
  end

  local function add(depth, text)
    table.insert(output, string.rep(indent, depth) .. text)
  end

  for key, value in pairs(tbl) do
    if (key and type(key) == "number" or type(key) == "string") then
      key = string.format("[\"%s\"]", key);

      if (type(value) == "table") then
        if (next(value)) then
          add(depth, key .. " = " .. start_bracket);
          add(0, stringify_table_ng(value, depth + 1, for_tex));
          add(depth, end_bracket .. ",");
        else
          add(depth, key .. " = " .. start_bracket .. end_bracket .. ",");
        end
      else
        if (type(value) == "string") then
          value = string.format("\"%s\"", value);
        else
          value = tostring(value);
        end

        add(depth, key .. " = " .. value .. ",");
      end
    end
  end

  return table.concat(output, line_break)
end

return {

  stringify_table = stringify_table,

  print_table = function(table)
    print(stringify_table_ng(table))
    --print(stringify_table(table, false))
  end,

  configure = function(options)
    for key, value in pairs(options) do
      if settings[key] ~= nil then
        settings[key] = value
      else
        print('Unknown config key: ' .. key)
      end
    end
  end,

  --- Parse a LaTeX/TeX style key-value string into a Lua table. With
  -- this function you should be able to parse key-value strings like
  -- this example:
  --
  --     show,
  --     hide,
  --     'string,with,commas inside single quotes',
  --     key with spaces = String without quotes,
  --     string="String with double quotes: ,{}=",
  --     dimension = 1cm,
  --     number = 2,
  --     float = 1.2,
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
  --       'string,with,commas inside single quotes',
  --       ['key with spaces'] = 'String without quotes',
  --       string = 'String with double quotes: ,{}=',
  --       dimension = '1cm',
  --       number = 2,
  --       float = 1.2,
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
  --
  -- @treturn table A hopefully properly parsed table you can
  -- do something useful with.
  parse = function (input)
    print(input)
    if input == nil then
      return {}
    end
    local parser = generate_parser()
    return normalize(parser:match(input))
  end
}
