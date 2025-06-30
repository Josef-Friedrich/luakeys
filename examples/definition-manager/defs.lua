require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

it('Field “.defs”', function()
  local manager = DefinitionManager({
    key1 = { default = 1 },
    key2 = { default = 2 },
    key3 = { default = 3 },
  })
  manager.defs.key1.default = 2
  assert.are.same(manager.defs, {
    key1 = { default = 2 },
    key2 = { default = 2 },
    key3 = { default = 3 },
  })
end)
