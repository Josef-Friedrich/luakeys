--- Code to embed into other lua files.
--
-- @module luakeys-lpeg-parser

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

  return Pattern({
    'list',
    value =
      Variable('object') +
      Variable('bool_value') +
      Variable('number_value') +
      Variable('string_value') +
      Variable('string_value_unquoted'),

    bool_value =
      boolean_true * capture_constant(true) +
      boolean_false * capture_constant(false),

    string_value =
      white_space * Pattern('"') *
      capture((Pattern('\\"') + 1 - Pattern('"'))^0) *
      Pattern('"') * white_space,

    string_value_unquoted =
      white_space *
      capture((1 - Set('{},='))^1) *
      white_space,

    number_value =
      white_space * (number / tonumber) * white_space,

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

return generate_parser
