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
--
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

local white_space = Set(' \t\r\n')^0

local function WsPattern(input)
  return white_space * Pattern(input) * white_space
end

--- Define data type boolean.
--
-- @return Lpeg patterns
local function data_type_boolean ()
  local boolean_true = (
    Pattern('true') +
    Pattern('TRUE') +
    Pattern('yes') +
    Pattern('YES') +
    Pattern('1')
  ) * capture_constant(true)

  local boolean_false = (
    Pattern('false') +
    Pattern('FALSE') +
    Pattern('no') +
    Pattern('NO') +
    Pattern('0')
  ) * capture_constant(false)

  return boolean_true + boolean_false
end

--- Define data type integer.
--
-- @return Lpeg patterns
local function data_type_integer()
  -- patt / function
  -- Creates a function capture. It calls the given function passing
  -- all captures made b nby patt as arguments, or the whole match if
  -- patt made no capture. The values returned by the function are the
  -- final values of the capture. In particular, if function returns
  -- no value, there is no captured value
  return Range('09')^1 / tonumber
end

--- Define data type integer.
--
-- @return Lpeg patterns
local function data_type_float()
  -- patt / function
  local digits = Range('09')^1
  local puls_minus = Set('+-')^-1
  return
  puls_minus * digits *
    (Pattern('.') * digits)^-1 *
    (Set('eE') * puls_minus * digits)^-1
    / tonumber
end

--- Define data type dimension.
--
-- @return Lpeg patterns
local function data_type_dimension()
  local sign = Set('-+')
  local integer = Range('09')^1
  local number = integer^1 * Set('.,')^0 * integer^0
  local unit
  -- https://raw.githubusercontent.com/latex3/lualibs/master/lualibs-util-dim.lua
  for _, dimension_extension in ipairs({'bp', 'cc', 'cm', 'dd', 'em', 'ex', 'in', 'mm', 'nc', 'nd', 'pc', 'pt', 'sp'}) do
    if unit then
      unit = unit + Pattern(dimension_extension)
    else
      unit = Pattern(dimension_extension)
    end
  end

  -- patt / function -> function capture
  return (sign^0 * white_space * number * white_space * unit) / tex.sp
end

--- Define data type string.
--
-- @return Lpeg patterns
local data_type_string = function()
  return capture(Range('az', 'AZ', '09')^1)
end

local data_types = {
  boolean = data_type_boolean(),
  integer = data_type_integer(),
  float = data_type_float(),
  dimension = data_type_dimension(),
  string = data_type_string(),
}

local capture_key_value_pair = function(arg1, arg2)
  print(arg1)
  print(arg2)
  return arg1, arg2
end

---
--
-- @tparam string key
-- @tparam table definition keys: alias, type
--
-- @treturn userdata Lpeg patterns etc.
local build_single_key_value_definition = function(key, definition)
  local key_pattern
  local destination_key_name
  local value_pattern

  -- Build the key pattern.
  if definition.rename_key then
    destination_key_name = definition.rename_key
  else
    destination_key_name = key
  end

  if definition.alias then
    -- alias = {'mlines', 'minlines'}
    if type(definition.alias) == 'table' then
      key_pattern = Pattern(key)
      for _, value in ipairs(definition.alias) do
        key_pattern = key_pattern + Pattern(value)  -- long alias first: 'bool', 'b'
      end
      key_pattern = (key_pattern) * capture_constant(destination_key_name)
    -- alias = 'minlines'
    else
      key_pattern =
        (Pattern(key) + Pattern(definition.alias)) *
        capture_constant(destination_key_name)
    end
  else
    if definition.rename_key then
      -- old_key=1 -> new_key=1
      key_pattern = Pattern(key) * capture_constant(destination_key_name)
    else
      key_pattern = capture(Pattern(key))
    end
  end

  -- Build the value pattern.
  if definition.data_type == 'keyonly' then
    -- show -> show=true
    value_pattern = capture_constant(true)
  elseif definition.overwrite_value ~= nil then
    value_pattern = capture_constant(definition.overwrite_value)
  else
    -- key=value
    value_pattern =
      WsPattern('=') *
      data_types[definition.data_type]
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
  for key, definition in pairs(definitions) do
    if definition['default'] ~= nil then
      defaults[key] = definition.default
    end
  end
  return defaults
end

--- Build a key value parser using Lpeg.
--
-- @tparam table definitions
--
-- @treturn parser The Lpeg parser
-- @treturn table defaults
local function build_parser(definitions)
  local key_values

  for key, definition in pairs(definitions) do
    local key_value = build_single_key_value_definition(key, definition)

    if not key_values then
      key_values = key_value
    else
      key_values = key_values + key_value
    end
  end

  -- Catch left over keys or key value pairs for error reportings
  local generic_catcher =
    capture(Range('az')^1) *
    WsPattern('=')^-1 *
    capture(Range('09', 'az', 'AZ')^0) / capture_key_value_pair

  local keyval_groups = capture_group((key_values + generic_catcher) * WsPattern(',')^-1 )

  -- rawset (table, index, value)
  -- Sets the real value of table[index] to value, without invoking the
  -- __newindex metamethod. table must be a table, index any value
  -- different from nil and NaN, and value any Lua value.
  return capture_fold(capture_table('') * keyval_groups^0, rawset), build_defaults_table(definitions)
end

return {
  print_table = print_table,
  build_parser = build_parser,
}
