require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('naked', { default = 1 })
luakeys.debug(result) -- { naked = 1 }

it('result', function ()
  assert.are.same({ naked = 1 }, result)
end)

local result2 = luakeys.parse('naked')
luakeys.debug(result2) -- { naked = true }

it('result2', function ()
  assert.are.same({ naked = true }, result2)
end)
