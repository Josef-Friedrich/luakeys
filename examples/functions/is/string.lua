require('busted.runner')()
local luakeys = require('luakeys')
local equal = assert.is.equal

it('Function “string()”', function()
  -- true
  equal(luakeys.is.string('string'), true)
  equal(luakeys.is.string(''), true)
  -- false
  equal(luakeys.is.string(true), false)
  equal(luakeys.is.string(1), false)
  equal(luakeys.is.string(nil), false)
end)
