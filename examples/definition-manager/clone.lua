require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

  describe('Method “:clone()”', function()
    it('clone all definitions', function()
      local m = manager:clone()
      assert.is_not.equal(m, manager)
      assert.are.same(m:key_names(), { 'key1', 'key2', 'key3' })
    end)

    it('Option include', function()
      local m = manager:clone({ include = { 'key1', 'key2' } })
      assert.are.same(m:key_names(), { 'key1', 'key2' })
    end)

    it('Option exclude', function()
      local m = manager:clone({ exclude = { 'key1', 'key2' } })
      assert.are.same(m:key_names(), { 'key3' })
    end)
  end)
