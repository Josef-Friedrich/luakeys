require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

it('result', function()
  assert.is.equal(manager.defs.key1.default, 1)
  assert.is.equal(manager.defs.key2.default, 2)
end)

it(':get', function()
  assert.is.equal(manager:get('key3').default, 3)
end)

describe(':parse', function()
  it('default', function()
    local result = manager:parse('key3', { 'key3' })
    assert.is.equal(result.key3, 3)
  end)

  it('rename key', function()
    local result = manager:parse('new3', { { 'key3', 'new3' } })
    assert.is.equal(result.new3, 3)
  end)

  it('exception', function()
    assert.has_error(function()
      manager:parse('key1', { 'key3' })
    end, 'luakeys error [E019]: Unknown keys: “key1,”')
  end)
end)
