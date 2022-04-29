-- luakeys.lua
-- Copyright 2021-2022 Josef Friedrich
--
-- This work may be distributed and/or modified under the
-- conditions of the LaTeX Project Public License, either version 1.3c
-- of this license or (at your option) any later version.
-- The latest version of this license is in
--   http://www.latex-project.org/lppl.txt
-- and version 1.3c or later is part of all distributions of LaTeX
-- version 2008/05/04 or later.
--
-- This work has the LPPL maintenance status `maintained'.
--
-- The Current Maintainer of this work is Josef Friedrich.
--
-- This work consists of the files luakeys.lua, luakeys.sty, luakeys.tex
-- luakeys-debug.sty and luakeys-debug.tex.

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
-- * [TUGboat article: Parsing complex data formats in LuaTEX with LPEG](https://tug.org/TUGboat/tb40-2/tb125menke-Patterndf)
--
-- @module luakeys

local lpeg = require('lpeg')
local Variable = lpeg.V
local Pattern = lpeg.P
local Set = lpeg.S
local Range = lpeg.R
local CaptureGroup = lpeg.Cg
local CaptureFolding = lpeg.Cf
local CaptureTable = lpeg.Ct
local CaptureConstant = lpeg.Cc
local CaptureSimple = lpeg.C

if not tex then
  tex = {}

  -- Dummy function for the tests.
  tex['sp'] = function (input)
    return 1234567
  end
end

if not token then
  token = {}
  token['set_macro'] = function (csname, content, global)

  end
end

--- Option handling
-- @section

--- This table stores all allowed option keys.
local option_keys = {
  'convert_dimensions',
  'unpack_single_array_values',
  'standalone_as_true',
  'converter',
  'case_insensitive_keys',
  'debug',
}

--- The default options.
local default_options = {
  convert_dimensions = true,
  unpack_single_array_values = true,
  standalone_as_true = false,
  debug = false,
}

local function throw_error(message)
  if type(tex.error) == 'function' then
    tex.error(message)
  else
    error(message)
  end
end

local l3_code_cctab = 10

local function set_l3_code_cctab (cctab_id)
  l3_code_cctab = cctab_id
end

--- Convert a key so that it can be written as a table field without
--  quotes and square brackets (for example `one 2` becomes `one_2`).
--  The key can then reference values from a table using dot notation.
--  (`table["one 2"]` becomes `table.one_2`).
--
-- @tparam string key The key to be converted.
--
-- @treturn string The converted key.
local function luafy_key(key)
  return key:gsub('[^%w]+', '_')
end

--- Convert all keys in a table to strings containig only alphanumeric
-- characters and underscores.
--
-- @param raw_options Some raw options.
--
-- @treturn table Returns always a table. If the input value is not a
-- an empty table is returned.
local function luafy_options(raw_options)
  if type(raw_options) ~= 'table' then
    raw_options = {}
  end
  local options = {}
  for key, value in pairs(raw_options) do
    options[luafy_key(key)] = value
  end
  return options
end

--- All option keys can be written with underscores or with spaces as
-- separators.
-- For the LaTeX version of the macro
--  `\luakeysdebug[options]{kv-string}`.
--
-- @tparam table options_raw Options in a raw format. The table may be
-- empty or some keys are not set.
--
-- @treturn table
local function normalize_parse_options (options_raw)
  options_raw = luafy_options(options_raw)
  local options = {}

  for _, option_name in ipairs(option_keys) do
    if options_raw[option_name] ~= nil then
      options[option_name] = options_raw[option_name]
    else
      options[option_name] = default_options[option_name]
    end
  end

  return options
end

--- Convert back to strings
-- @section

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
local function render (tbl)
  local function render_inner(tbl)
    local output = {}
    local function add(text)
      table.insert(output, text)
    end
    for key, value in pairs(tbl) do
      if (key and type(key) == 'string') then
        if (type(value) == 'table') then
          if (next(value)) then
            add(key .. '={')
            add(render_inner(value))
            add('},')
          else
            add(key .. '={},')
          end
        else
          add(key .. '=' .. tostring(value) .. ',')
        end
      else
        add(tostring(value) .. ',')
      end
    end
    return table.concat(output)
  end
  return render_inner(tbl)
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
    start_bracket = '$\\{$'
    end_bracket = '$\\}$'
    indent = '\\ \\ '
  else
    line_break = '\n'
    start_bracket = '{'
    end_bracket = '}'
    indent = '  '
  end

  local function stringify_inner(input, depth)
    local output = {}
    depth = depth or 0

    local function add(depth, text)
      table.insert(output, string.rep(indent, depth) .. text)
    end

    local function format_key(key)
      if (type(key) == 'number') then
        return string.format('[%s]', key)
      else
        return string.format('[\'%s\']', key)
      end
    end

    if type(input) ~= 'table' then
      return tostring(input)
    end

    for key, value in pairs(input) do
      if (key and type(key) == 'number' or type(key) == 'string') then
        key = format_key(key)

        if (type(value) == 'table') then
          if (next(value)) then
            add(depth, key .. ' = ' .. start_bracket)
            add(0, stringify_inner(value, depth + 1))
            add(depth, end_bracket .. ',');
          else
            add(depth, key .. ' = ' .. start_bracket .. end_bracket .. ',')
          end
        else
          if (type(value) == 'string') then
            value = string.format('\'%s\'', value)
          else
            value = tostring(value)
          end

          add(depth, key .. ' = ' .. value .. ',')
        end
      end
    end

    return table.concat(output, line_break)
  end

  return start_bracket .. line_break .. stringify_inner(input, 1) .. line_break .. end_bracket
end

--- The function `pretty_print(tbl)` pretty prints a Lua table to standard
--   output (stdout). It is a utility function that can be used to
--   debug and inspect the resulting Lua table of the function
--   `parse`. You have to compile your TeX document in a console to
--   see the terminal output.
--
-- @tparam table tbl A table to be printed to standard output for
-- debugging purposes.
local function pretty_print(tbl)
  print(stringify(tbl, false))
end

--- Parser / Lpeg related
-- @section

--- Generate the PEG parser using Lpeg.
--
-- @treturn userdata The parser.
local function generate_parser(initial_rule, options)
  -- Optional whitespace
  local white_space = Set(' \t\n\r')

  --- Match literal string surrounded by whitespace
  local ws = function(match)
    return white_space^0 * Pattern(match) * white_space^0
  end

  local capture_dimension = function (input)
    if options.convert_dimensions then
      return tex.sp(input)
    else
      return input
    end
  end

  --- Add values to a table in two modes:
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

  return Pattern({
    [1] = initial_rule,

    -- list_item*
    list = CaptureFolding(
      CaptureTable('') * Variable('list_item')^0,
      add_to_table
    ),

    -- '{' list '}'
    list_container =
      ws('{') * Variable('list') * ws('}'),

    -- ( list_container / key_value_pair / value ) ','?
    list_item =
      CaptureGroup(
        Variable('list_container') +
        Variable('key_value_pair') +
        Variable('value')
      ) * ws(',')^-1,

    -- key '=' (list_container / value)
    key_value_pair =
      (Variable('key') * ws('=')) * (Variable('list_container') + Variable('value')),

    -- number / string_quoted / string_unquoted
    key =
      Variable('number') +
      Variable('string_quoted') +
      Variable('string_unquoted'),

    -- boolean !value / dimension !value / number !value / string_quoted !value / string_unquoted
    -- !value -> Not-predicate -> * -Variable('value')
    value =
      Variable('boolean') * -Variable('value') +
      Variable('dimension') * -Variable('value') +
      Variable('number') * -Variable('value')  +
      Variable('string_quoted') * -Variable('value') +
      Variable('string_unquoted'),

    -- boolean_true / boolean_false
    boolean =
      (
        Variable('boolean_true') * CaptureConstant(true) +
        Variable('boolean_false') * CaptureConstant(false)
      ),

    boolean_true =
      Pattern('true') +
      Pattern('TRUE') +
      Pattern('True'),

    boolean_false =
      Pattern('false') +
      Pattern('FALSE') +
      Pattern('False'),

    dimension = (
      Variable('sign')^0 * white_space^0 *
      Variable('tex_number') * white_space^0 *
      Variable('unit')
    ) / capture_dimension,

    number =
      (white_space^0 * (Variable('lua_number') / tonumber) * white_space^0) ,

    tex_number =
      (Variable('integer')^1 * (Pattern('.') * Variable('integer')^1)^0) +
      (Pattern('.') * Variable('integer')^1),

    -- 'bp' / 'BP' / 'cc' / etc.
    -- https://raw.githubusercontent.com/latex3/lualibs/master/lualibs-util-dim.lua
    unit =
      Pattern('bp') + Pattern('BP') +
      Pattern('cc') + Pattern('CC') +
      Pattern('cm') + Pattern('CM') +
      Pattern('dd') + Pattern('DD') +
      Pattern('em') + Pattern('EM') +
      Pattern('ex') + Pattern('EX') +
      Pattern('in') + Pattern('IN') +
      Pattern('mm') + Pattern('MM') +
      Pattern('nc') + Pattern('NC') +
      Pattern('nd') + Pattern('ND') +
      Pattern('pc') + Pattern('PC') +
      Pattern('pt') + Pattern('PT') +
      Pattern('sp') + Pattern('SP'),

    lua_number =
      Variable('int') *
      Variable('frac')^-1,

    int = Variable('sign')^-1 * (
      Range('19') * Variable('integer') + Variable('integer')
    ),

    frac = Pattern('.') * Variable('integer'),
    sign = Set('-+'),
    integer = Range('09')^1,

    -- '"' ('\"' / !'"')* '"'
    string_quoted =
      white_space^0 * Pattern('"') *
      CaptureSimple((Pattern('\\"') + 1 - Pattern('"'))^0) *
      Pattern('"') * white_space^0,

    string_unquoted =
      white_space^0 *
      CaptureSimple(
        Variable('word_unquoted')^1 *
        (Set(' \t')^1 * Variable('word_unquoted')^1)^0) *
      white_space^0,

    word_unquoted = (1 - white_space - Set('{},='))^1
  })
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
-- `{ 1 }` into `1`.
--
-- @treturn If the value is a array like table with one non table typed
-- value in it, the unpacked value, else the unchanged input.
local function unpack_single_valued_array_table(value, options)
  if
    type(value) == 'table' and
    get_array_size(value) == 1 and
    get_table_size(value) == 1 and
    type(value[1]) ~= 'table'
  then
    if type(value[1]) == 'string' and options.standalone_as_true then
      return value
    else
      return value[1]
    end
  end
  return value
end

local function remove_from_array(array, element)
  for index, value in pairs(array) do
    if element == value then
      array[index] = nil
      return value
    end
  end
end

local function visit_parse_tree(parse_tree, callback_func)
  if type(parse_tree) ~= 'table' then
    throw_error('Parse tree has to be a table')
  end
  local function visit_parse_tree_recursive(root_table, current_table, result, depth, callback_func)
    for key, value in pairs(current_table) do
      if type(value) == 'table' then
        value = visit_parse_tree_recursive(root_table, value, {}, depth + 1, callback_func)
      end

      key, value = callback_func(key, value, depth, current_table, root_table)

      if key ~= nil and value ~= nil then
        result[key] = value
      end
    end
    if next(result) ~= nil then
      return result
    end
  end

  return visit_parse_tree_recursive(parse_tree, parse_tree, {}, 1, callback_func)
end

--- Normalize the result tables of the LPeg parser. This normalization
--  tasks are performed on the raw input table coming directly from the
--  PEG parser:
--
-- * Unpack all single valued array like tables: `{ 'text' }` into
--    `text`
--
-- @tparam table raw The raw input table coming directly from the PEG
--   parser
--
-- @tparam table options Some options. A table with the key
--   `unpack_single_array_values`
--
-- @treturn table A normalized table ready for the outside world.
local function normalize(raw, options)
  local function normalize_recursive(raw, result, options)
    for key, value in pairs(raw) do
      if options.unpack_single_array_values then
        value = unpack_single_valued_array_table(value, options)
      end
      if type(value) == 'table' then
        result[key] = normalize_recursive(value, {}, options)
      else
        result[key] = value
      end
    end
    return result
  end
  raw = normalize_recursive(raw, {}, options)

  if options.standalone_as_true then
    raw = visit_parse_tree(raw, function (key, value)
      if type(key) == 'number' and type(value) == 'string' then
        return value, true
      end
      return key, value
    end)
  end

  if options.case_insensitive_keys then
    raw = visit_parse_tree(raw, function (key, value)
      if type(key) == 'string' then
        return key:lower(), value
      end
      return key, value
    end)
  end

  return raw
end

--- Parse a LaTeX/TeX style key-value string into a Lua table.
--
-- @tparam string kv_string A string in the TeX/LaTeX style key-value
--   format as described above.
--
-- @tparam table options A table containing the settings:
-- `convert_dimensions`, `unpack_single_array_values`,
-- `standalone_as_true`, `converter`, `debug`.
--
-- @treturn table A hopefully properly parsed table you can do something
-- useful with.
local function parse (kv_string, options)
  if kv_string == nil then
    return {}
  end
  options = normalize_parse_options(options)

  local parser = generate_parser('list', options)
  local parse_tree = parser:match(kv_string)

  if options.converter ~= nil and type(options.converter) == 'function' then
    parse_tree = visit_parse_tree(parse_tree, options.converter)
  end
  local result= normalize(parse_tree, options)
  if options.debug then
    pretty_print(result)
  end
  return result
end

local is = {
  dimension = function (str)
    local parser = generate_parser('dimension', {convert_dimensions = false})
    local result = parser:match(str)
    return result ~= nil
  end,

  integer = function (str)
    local n = tonumber(str)
    if n == nil then return false end
    return n == math.floor(n)
  end,
}

local function apply_definitions(defs, input, output)
  for index, def in pairs(defs) do
    --- Find key and def
    local key
    if type(def) == 'table' and def.name == nil and type(index) == 'string' then
      key = index
    elseif type(def) == 'table' and def.name ~= nil then
      key = def.name
    elseif type(index) == 'number' and type(def) == 'string' then
      key = def
      def = { default = true }
    end

    if type(def) ~= 'table' then
      throw_error('Key definition must be a table')
    end

    if key == nil then
      throw_error('key name couldn’t be detected!')
    end

    local function find_value(search_key)
      if input[search_key] ~= nil then
        local value = input[search_key]
        input[search_key] = nil
        return value
      --- standalone value: values with integer keys
      elseif remove_from_array(input, search_key) ~= nil then
        return def.default
      end
    end

    -- find value
    local value = find_value(key)

    -- def.alias
    if value == nil and def.alias ~= nil then
      if type(def.alias) == 'string' then
        def.alias = { def.alias }
      end
      for _, alias in ipairs(def.alias) do
        value = find_value(alias)
        if value ~= nil then
          break
        end
      end
    end

    -- opposite_values
    if def.opposite_values ~= nil then
      local true_value = def.opposite_values[true]
      local false_value = def.opposite_values[false]
      if true_value == nil or false_value == nil then
        throw_error('Usage opposite_values = { [true] = "...", [false] = "..." }')
      end
      if remove_from_array(input, true_value) ~= nil then
        output[key] = true
      elseif remove_from_array(input, false_value) ~= nil then
        output[key] = false
      end
    end

    -- always_present
    -- default
    if def.default ~= nil and value == nil and def.always_present then
      value = def.default
    end

    -- macro
    if def.macro ~= nil then
      token.set_macro(def.macro, value, 'global')
    end

    if value == nil then
      break
    end

    --- values indexed by key name

    -- sub_keys
    if def.sub_keys ~= nil and type(value) == 'table' then
      output[key] = {}
      apply_definitions(def.sub_keys, value, output[key])
      break
    end

    -- l3_tl_set
    if def.l3_tl_set ~= nil then
      tex.print(l3_code_cctab, '\\tl_set:Nn \\g_' .. def.l3_tl_set .. '_tl')
      tex.print('{' .. value .. '}')
      break
    end

    if value ~= nil then
      output[key] = value
    end
  end
  return output
end

local function define(defs, options)
  return function (kv_string)
    local leftover = parse(kv_string, options)
    local result = {}
    apply_definitions(defs, leftover,  result)
    return result, leftover
  end
end

--- Store results
-- @section

--- A table to store parsed key-value results.
local result_store = {}

--- The function `save(identifier, result): void` saves a result (a
--  table from a previous run of `parse`) under an identifier.
--  Therefore, it is not necessary to pollute the global namespace to
--  store results for the later usage.
--
-- @tparam string identifier The identifier under which the result is
--   saved.
--
-- @tparam table result A result to be stored and that was created by
--   the key-value parser.
local function save(identifier, result)
  result_store[identifier] = result
end

--- The function `get(identifier): table` retrieves a saved result
--  from the result store.
--
-- @tparam string identifier The identifier under which the result was
--   saved.
local function get(identifier)
  -- if result_store[identifier] == nil then
  --   throw_error('No stored result was found for the identifier \'' .. identifier .. '\'')
  -- end
  return result_store[identifier]
end

--- Exports
-- @section

local export = {
  --- @see default_options
  default_options = default_options,

  --- @see stringify
  stringify = stringify,

  --- @see parse
  parse = parse,

  --- @see define
  define = define,

  --- @see render
  render = render,

  --- @see pretty_print
  print = pretty_print,

  --- @see save
  save = save,

  --- @see get
  get = get,

  is = is,
}

-- http://olivinelabs.com/busted/#private
if _TEST then
  export.luafy_key = luafy_key
  export.luafy_options = luafy_options
  export.normalize = normalize
  export.normalize_parse_options = normalize_parse_options
  export.unpack_single_valued_array_table = unpack_single_valued_array_table
  export.visit_parse_tree = visit_parse_tree
  export.apply_definitions = apply_definitions
end

return export
