require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('dim=1cm', {
  convert_dimensions = true,
})
-- result = { dim = 1864679 }

it('true', function ()
  assert.are.same({ dim = 1234567 }, result)
end)

local result = luakeys.parse('dim=1cm', {
  convert_dimensions = false,
})
-- or
result = luakeys.parse('dim=1cm')
-- result = { dim = '1cm' }

it('true', function ()
  assert.are.same({ dim = '1cm' }, result)
end)
