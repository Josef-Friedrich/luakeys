require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

    it('clone = false', function()
      local defs = manager:exclude({ 'key3' })
      assert.is.equal(defs.key1.default, 1)
      assert.is.equal(defs.key2.default, 2)
      assert.is.equal(defs.key3, nil)
      ---@diagnostic disable-next-line: undefined-field
      assert.is.equal(defs.key1, manager.defs.key1)
    end)

    it('clone = true', function()
      local defs = manager:exclude({ 'key3' }, true)
      ---@diagnostic disable-next-line: undefined-field
      assert.is_not.equal(defs.key1, manager.defs.key1)
    end)
