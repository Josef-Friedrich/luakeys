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
-- @module luakeys

local lpeg = require('lpeg')

--- See [lpeg.P](http://www.inf.puc-rio.br/~roberto/lpeg#op-p)
--
-- Like `('literal')` in peg.js.
local Pattern = lpeg.P

--- See [lpeg.R](http://www.inf.puc-rio.br/~roberto/lpeg#op-r)
--
-- Like `[a-z]` in peg.js.
local Range = lpeg.R

--- See [lpeg.S](http://www.inf.puc-rio.br/~roberto/lpeg#op-s)
--
-- Like `[characters]` in peg.js.
local Set = lpeg.S

--- See [lpeg.S](http://www.inf.puc-rio.br/~roberto/lpeg#op-v)
local Variable = lpeg.V

--- See [lpeg.C](http://www.inf.puc-rio.br/~roberto/lpeg#cap-c)
local capture = lpeg.C

--- See [lpeg.Ct](http://www.inf.puc-rio.br/~roberto/lpeg#cap-t)
local capture_table = lpeg.Ct

--- See [lpeg.Cf](http://www.inf.puc-rio.br/~roberto/lpeg#cap-f)
local capture_fold = lpeg.Cf

--- See [lpeg.Cg](http://www.inf.puc-rio.br/~roberto/lpeg#cap-g)
local capture_group = lpeg.Cg

local inspect = require('inspect')

-- number parsing
local number = Pattern({('number'),
  number = (
    Variable('int') *
    Variable('frac')^-1 *
    Variable('exp')^-1
  ) / tonumber,

  int = Variable('sign')^-1 * (
    Range('19') * Variable('digits') + Variable('digit')
  ),

  sign = Set('+-'),

  digit = Range('09'),

  digits = Variable('digit') * Variable('digits') + Variable('digit'),

  frac = Pattern('.') * Variable('digits'),

  exp = Set('eE') * Variable('sign')^-1 * Variable('digits'),
})

-- optional whitespace
local white_space = Set(' \t\n\r')^0

--- Match literal string surrounded by whitespace
local WhiteSpacedPattern = function(match)
  return white_space * Pattern(match) * white_space
end

--- Match literal string and synthesize
-- an attribute
local synthesize_capture = function(match, capture)
  return
    white_space *
    Pattern(match) / function() return capture end *
    white_space
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
-- If arg2 is nil, then arg1 is the value and is add as a indexed (by an
-- integer) value
--
-- @tparam table table @tparam mixed arg1 @tparam mixed arg2 If arg2 is
-- empty
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

local keys_grammar = Pattern({
  'list',
  value =
    Variable('object') +
    Variable('bool_value') +
    Variable('number_value') +
    Variable('string_value') +
    Variable('string_value_unquoted'),

  bool_value =
    synthesize_capture(('true'), true) + synthesize_capture(('false'), false),

  string_value =
    white_space * Pattern('"') *
    capture((Pattern('\\"') + 1 - Pattern('"'))^0) *
    Pattern('"') * white_space,

  string_value_unquoted =
    white_space *
    capture((1 - Set('{},='))^1) *
    white_space,

  number_value =
    white_space * number * white_space,

  key_word = Range('az', 'AZ', '09'),

  key = white_space * capture(
    Variable('key_word')^1 *
    (Pattern(' ')^1 * Variable('key_word')^1)^0
  ) * white_space,

  value_without_key =
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

local input = [[
  show,hide, "lol,lol",
  key with spaces = String without quotes,
  string= "String with quotes: ,{}=",
  number = 2,
  float = 1.2,
  list = {one=one,two=two,three=three},
  nested key = {
    nested key 2= {
      key = value,
    },
  },
]]

print(inspect(keys_grammar:match(input)))