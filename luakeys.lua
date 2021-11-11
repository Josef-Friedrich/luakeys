-- luakeys.lua
-- Copyright 2021 Josef Friedrich
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

--- A table to store parsed key-value results.
local result_store = {}

--- Generate the PEG parser using Lpeg.
--
-- @treturn userdata The parser.
local function generate_parser(options)
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
      return CaptureSimple(input)
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
    'list',

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

    -- value '=' (list_container / value)
    key_value_pair =
      (Variable('key') * ws('=')) * (Variable('list_container') + Variable('value')),

    key =
      Variable('number') +
      Variable('string_quoted') +
      Variable('string_unquoted'),

    -- boolean / dimension / number / string_quoted / string_unquoted
    value =
      Variable('boolean') +
      Variable('dimension') +
      Variable('number') +
      Variable('string_quoted') +
      Variable('string_unquoted'),

    -- boolean_true / boolean_false
    boolean =
      (
        Variable('boolean_true') * CaptureConstant(true) +
        Variable('boolean_false') * CaptureConstant(false)
      ) * -Variable('string_unquoted'),

    boolean_true =
      Pattern('true') +
      Pattern('TRUE') +
      Pattern('True'),

    boolean_false =
      Pattern('false') +
      Pattern('FALSE') +
      Pattern('False'),

    sign = Set('-+'),

    integer = Range('09')^1,

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

    dimension = (Variable('sign')^0 * white_space^0 * Variable('tex_number') * white_space^0 * Variable('unit')) / capture_dimension,

    number =
      white_space^0 * (Variable('lua_number') / tonumber) * white_space^0,

    lua_number =
      Variable('int') *
      Variable('frac')^-1 *
      Variable('exp')^-1,

    int = Variable('sign')^-1 * (
      Range('19') * Variable('digits') + Variable('digit')
    ),

    digit = Range('09'),
    digits = Variable('digit') * Variable('digits') + Variable('digit'),
    frac = Pattern('.') * Variable('digits'),
    exp = Set('eE') * Variable('sign')^-1 * Variable('digits'),

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

    word_unquoted = (1 - white_space - Set('{},='))^1;
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

--- This normalization tasks are performed on the raw input table coming
--  directly from the PEG parser:
--
-- 1. Trim all strings: ` text \n` into `text`
-- 2. Unpack all single valued array like tables: `{ 'text' }` into
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
        value = unpack_single_valued_array_table(value)
      end
      if type(value) == 'table' then
        result[key] = normalize_recursive(value, {}, options)
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
    depth = depth or 0;

    local function add(depth, text)
      table.insert(output, string.rep(indent, depth) .. text)
    end

    if type(input) ~= 'table' then
      return tostring(input)
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
  --
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
    options = normalize_parse_options(options)

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
  save = function(identifier, result)
    result_store[identifier] = result
  end,

  --- The function `get(identifier): table` retrieves a saved result
  --  from the result store.
  --
  -- @tparam string identifier The identifier under which the result was
  --   saved.
  get = function(identifier)
    return result_store[identifier]
  end,

}
