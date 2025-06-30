require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

it('Method: parse', function()
  -- key_selection=nil: use all defintions
  local result = manager:parse('key1,key2,key3')
  assert.are.same(result, {
    key1 = 1, key2 = 2, key3 = 3 }
  )

  -- key_selection=key3
  local result = manager:parse('key3', { 'key3' })
  assert.is.equal(result.key3, 3)

  -- rename key
  local result = manager:parse('new3', { key3 = 'new3' })
  assert.is.equal(result.new3, 3)

  -- exception
  assert.has_error(function()
    manager:parse('key1', { 'key3' })
  end, 'luakeys error [E019]: Unknown keys: “key1,”')
end)
