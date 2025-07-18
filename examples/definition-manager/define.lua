require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

it('Method: define', function()
  local parse = manager:define({
    key1 = 'new1'
  })

  local result = parse('new1')
  assert.are.same(result, {
    new1 = 1 }
  )

  -- exception
  assert.has_error(function()
    parse('key1')
  end, 'luakeys error [E019]: Unknown keys: “key1”')
end)
