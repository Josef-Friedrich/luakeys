require('busted.runner')()
local luakeys = require('luakeys')
local equal = assert.is.equal

it('Function “number()”', function()
  -- true
  equal(luakeys.is.number('1'), true) -- input: string!
  equal(luakeys.is.number('1.1'), true) -- input: string!
  equal(luakeys.is.number(1), true)
  equal(luakeys.is.number(1.1), true)
  -- false
  equal(luakeys.is.number('xxx'), false)
  equal(luakeys.is.number('1cm'), false)
end)
