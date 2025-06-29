require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

it('Method :clone()', function()
  -- argument: clone = nil
  local defs1 = manager:exclude({ 'key3' })
  assert.is.equal(defs1.key1.default, 1)
  assert.is.equal(defs1.key2.default, 2)
  assert.is.equal(defs1.key3, nil)
  assert.is.equal(defs1.key1, manager.defs.key1)

  -- argument: clone = true
  local defs2 = manager:exclude({ 'key3' }, true)
  assert.is_not.equal(defs2.key1, manager.defs.key1)

  -- argument: key_spec = nil -> all definitions are returned'
  local defs3 = manager:exclude()
  assert.are.same(defs3, {
    key1 = { default = 1 },
    key2 = { default = 2 },
    key3 = { default = 3 },
  })
end)
