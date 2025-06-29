require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

it('Method clone', function()
  local manager = DefinitionManager({
    key1 = { default = 1 },
    key2 = { default = 2 },
    key3 = { default = 3 },
  })

  local clone1 = manager:clone()
  assert.is_not.equal(clone1, manager)
  assert.are.same(clone1:key_names(), { 'key1', 'key2', 'key3' })

  -- option include
  local clone2 = manager:clone({ include = { 'key1' } })
  assert.are.same(clone2:key_names(), { 'key1' })

  -- option exclude
  local clone3 = manager:clone({ exclude = { 'key1' } })
  assert.are.same(clone3:key_names(), { 'key2', 'key3' })
end)
