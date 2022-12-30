require('busted.runner')()
local luakeys = require('luakeys')()

local result = luakeys.parse('dim=1cm', {
  convert_dimensions = false,
})
-- or
result = luakeys.parse('dim=1cm')
-- result = { dim = '1cm' }

it('result', function ()
  assert.are.same({ dim = '1cm' }, result)
end)
