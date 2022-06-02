require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse(
  'level1={level2={naked,dim=1cm,bool=false,num=-0.001,str="lua,{}"}}',
  { convert_dimensions = true })
luakeys.debug(result)

local expected =
{
  ['level1'] = {
    ['level2'] = {
      ['naked'] = true,
      ['dim'] = 1234567,
      ['bool'] = false,
      ['num'] = -0.001,
      ['str'] = 'lua,{}',
    }
  }
}

it('result', function ()
  assert.is.same(expected, result)
end)
