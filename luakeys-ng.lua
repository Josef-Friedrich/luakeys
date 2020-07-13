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

--- See [lpeg.Cg](http://www.inf.puc-rio.br/~roberto/lpeg#cap-cc)
local capture_constant = lpeg.Cc
-- https://tug.org/TUGboat/tb40-2/tb125menke-lpeg.pdf

local inspect = require('inspect')

-- number parsing
local number = Pattern({('number'),
  number = (Variable('int') * Variable('frac')^-1 * Variable('exp')^-1) / tonumber,
  int = Variable('sign')^-1 * (Range('19') * Variable('digits') + Variable('digit')),
  sign = Set('+-'),
  digit = Range('09'),
  digits = Variable('digit') * Variable('digits') + Variable('digit'),
  frac = Pattern('.') * Variable('digits'),
  exp = Set('eE') * Variable('sign')^-1 * Variable('digits'),
})

-- optional whitespace
local white_space = Set(' \t\n\r')^0

-- match literal string surrounded by whitespace
local lit = function(str)
  return white_space * Pattern(str) * white_space
end

-- match literal string and synthesize
-- an attribute
local attr = function(str, attr)
  return white_space * Pattern(str) /
  function() return attr end * white_space
end

-- JSON grammar
local json = Pattern({
  'list',
  value =
    Variable('bool_value') +
    Variable('string_value') +
    Variable('number_value') +
    Variable('object'),

  bool_value =
    attr(('true'), true) + attr(('false'), false),

  string_value =
    white_space * Pattern('"') * capture((Pattern('\\"') + 1 - Pattern('"'))^0) * Pattern('"') * white_space,

  number_value =
    white_space * number * white_space,

  key_word = Range('az', 'AZ', '09'),

  key = white_space * capture(Variable('key_word')^1 * (Pattern(' ')^1 * Variable('key_word')^1)^0) * white_space,

  member_pair =
    capture_group(Variable('key') * lit('=') * Variable('value')) * lit(',')^-1,

  list = capture_fold(capture_table('') * Variable('member_pair')^0, rawset),

  object =
    lit('{') * Variable('list')  * lit('}')
})

local input = [[
    font size ="12",
    menu id= {
      id= "file",
      value= "File",
      pop up item= {
        menuitem= {
          value= "New",
          onclick = "CreateNewDoc()"
        }
      }
    }
]]

print(inspect(json:match(input)))
