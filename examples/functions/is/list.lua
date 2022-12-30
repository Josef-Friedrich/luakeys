require('busted.runner')()
local luakeys = require('luakeys')()
local equal = assert.is.equal

it('Function “list()”', function()
  -- true
  equal(luakeys.is.list({ 'one', 'two', 'three' }), true)
  equal(luakeys.is.list({ [1] = 'one', [2] = 'two', [3] = 'three' }),
    true)

  -- false
  equal(luakeys.is.list({ one = 'one', two = 'two', three = 'three' }),
    false)
  equal(luakeys.is.list('one,two,three'), false)
  equal(luakeys.is.list('list'), false)
  equal(luakeys.is.list(nil), false)
end)
