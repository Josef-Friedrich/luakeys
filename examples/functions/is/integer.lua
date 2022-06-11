require('busted.runner')()
local luakeys = require('luakeys')
local equal = assert.is.equal

it('Function “integer()”', function()
  -- true
  equal(luakeys.is.integer('42'), true) -- input: string!
  equal(luakeys.is.integer(1), true)
  -- false
  equal(luakeys.is.integer('1.1'), false)
  equal(luakeys.is.integer('xxx'), false)
end)
