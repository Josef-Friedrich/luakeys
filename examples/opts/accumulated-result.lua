require('busted.runner')()
local luakeys = require('luakeys')

it('First call', function()
  local result = {}

  luakeys.parse('key1=one', { accumulated_result = result })
  assert.are.same({ key1 = 'one' }, result)

  luakeys.parse('key2=two', { accumulated_result = result })
  assert.are.same({ key1 = 'one', key2 = 'two' }, result)

  luakeys.parse('key1=1', { accumulated_result = result })
  assert.are.same({ key1 = 1, key2 = 'two' }, result)
end)
