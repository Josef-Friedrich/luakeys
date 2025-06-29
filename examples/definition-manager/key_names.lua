require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

it('Method “:key_names()”', function()
  assert.is.same(manager:key_names(), {
    'key1',
    'key2',
    'key3' })
end)
