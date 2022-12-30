require('busted.runner')()
local luakeys = require('luakeys')()

local result = luakeys.parse('dim=1cm', {
  convert_dimensions = true,
})
-- result = { dim = 1864679 }

it('result', function ()
  assert.are.same({ dim = 1234567 }, result)
end)
