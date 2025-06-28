require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

describe('class “DefinitionManager()”', function()
  it('result', function()
    ---@diagnostic disable-next-line: undefined-field
    assert.is.equal(manager.defs.key1.default, 1)
    ---@diagnostic disable-next-line: undefined-field
    assert.is.equal(manager.defs.key2.default, 2)
  end)

  it('Constructor', function()
    local m = DefinitionManager({
      { name = 'named1', default = 1 },
      { name = 'named2', default = 2 },
      unnamed = { default = 0 },

    })
    assert.is.equal(m:get('named1').default, 1)
    assert.is.equal(m:get('named2').default, 2)
    assert.is.equal(m:get('unnamed').default, 0)
  end)

  it('Method “:get()”', function()
    assert.is.equal(manager:get('key3').default, 3)
  end)

  describe('Method “:include()”', function()
    it('clone = false', function()
      local defs = manager:include({ 'key3' })
      assert.is.equal(defs.key3.default, 3)
      ---@diagnostic disable-next-line: undefined-field
      assert.is.equal(defs.key3, manager.defs.key3)
    end)

    it('clone = true', function()
      local defs = manager:include({ 'key3' }, true)
      ---@diagnostic disable-next-line: undefined-field
      assert.is_not.equal(defs.key3, manager.defs.key3)
    end)
  end)

  describe('Method “:exclude()”', function()
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
  end)

  describe('Method “:parse()”', function()
    it('default', function()
      local result = manager:parse('key3', { 'key3' })
      assert.is.equal(result.key3, 3)
    end)

    it('rename key', function()
      local result = manager:parse('new3', { key3 = 'new3' })
      assert.is.equal(result.new3, 3)
    end)

    it('key_selection=nil: use all defintions ', function()
      local result = manager:parse('key1')
      assert.are.same(result, {
        key1 = 1 }
      )
    end)

    it('exception', function()
      assert.has_error(function()
        manager:parse('key1', { 'key3' })
      end, 'luakeys error [E019]: Unknown keys: “key1,”')
    end)
  end)
end)
