require('busted.runner')()
local luakeys = require('luakeys')()

local result = luakeys.parse('key=yes', {
  true_aliases = { 'true', 'TRUE', 'True' },
  false_aliases = { 'false', 'FALSE', 'False' },
})
luakeys.debug(result) -- { key = 'yes' }

it('result', function()
  assert.are.same({ key = 'yes' }, result)
end)

local result2 = luakeys.parse('key=yes', {
  true_aliases = { 'on', 'yes' },
  false_aliases = { 'off', 'no' },
})
luakeys.debug(result2) -- { key = true }

it('result2', function()
  assert.are.same({ key = true }, result2)
end)

local result3 = luakeys.parse('key=true', {
  true_aliases = { 'on', 'yes' },
  false_aliases = { 'off', 'no' },
})
luakeys.debug(result3) -- { key = 'true' }

it('result3', function()
  assert.are.same({ key = 'true' }, result3)
end)
