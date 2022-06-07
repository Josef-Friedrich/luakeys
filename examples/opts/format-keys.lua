require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('KEY=value', { format_keys = { 'lower' } })
luakeys.debug(result) -- { key = 'value' }

it('result', function()
  assert.are.same({ key = 'value' }, result)
end)

local result2 = luakeys.parse('snake case=value', { format_keys = { 'snake' } })
luakeys.debug(result2) -- { snake_case = 'value' }

it('result2', function()
  assert.are.same({ snake_case = 'value' }, result2)
end)

local result3 = luakeys.parse('key=value', { format_keys = { 'upper' } })
luakeys.debug(result3) -- { KEY = 'value' }

it('result3', function()
  assert.are.same({ KEY = 'value' }, result3)
end)
