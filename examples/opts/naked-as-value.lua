require('busted.runner')()
local luakeys = require('luakeys')()

local result = luakeys.parse('one,two,three')
luakeys.debug(result) -- { one = true, two = true, three = true }

it('result', function ()
  assert.are.same({ one = true, two = true, three = true }, result)
end)

local result2 = luakeys.parse('one,two,three', { naked_as_value = true })
luakeys.debug(result2)
-- { [1] = 'one', [2] = 'two', [3] = 'three' }
-- { 'one', 'two', 'three' }

it('result2', function ()
  assert.are.same({ 'one', 'two', 'three' }, result2)
end)
