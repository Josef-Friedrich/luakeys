require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

it('Method “:set()”', function()
  local m = manager:clone()
  m:set('key4', { default = 4 })
  assert.is.equal(m:get('key4').default, 4)
end)
