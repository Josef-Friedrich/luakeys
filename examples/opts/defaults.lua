require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('key1=new', {
  defaults = { key1 = 'default', key2 = 'default' },
})
luakeys.debug(result) -- { key1 = 'new', key2 = 'default' }

it('result', function ()
  assert.are.same({ key1 = 'new', key2 = 'default' }, result)
end)
