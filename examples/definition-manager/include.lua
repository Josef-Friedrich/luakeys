require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

it('Method :include', function()
  -- argument: clone = nil
  local defs1 = manager:include({ 'key3' })
  assert.is.equal(defs1.key3.default, 3)
  assert.is.equal(defs1.key3, manager.defs.key3)

  -- argument: clone = true
  local defs2 = manager:include({ 'key3' }, true)
  assert.is_not.equal(defs2.key3, manager.defs.key3)

  -- argument: key_spec = nil -> all definitions are returned'
  local defs3 = manager:include()
  assert.are.same(defs3, {
    key1 = { default = 1 },
    key2 = { default = 2 },
    key3 = { default = 3 },
  })
end)
