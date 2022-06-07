require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('key={string}', { unpack = true })
luakeys.debug(result) -- { key = 'string' }

it('result', function()
  assert.are.same({ key = 'string' }, result)
end)

local result2 = luakeys.parse('key={string}', { unpack = false })
luakeys.debug(result2) -- { key = { string = true } }

it('result2', function()
  assert.are.same({ key = { string = true } }, result2)
end)
