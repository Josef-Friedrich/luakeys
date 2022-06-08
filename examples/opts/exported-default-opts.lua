require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('dim=1cm') -- { dim = '1cm' }

it('result', function()
  assert.is.same({ dim = '1cm' }, result)
end)

luakeys.opts.convert_dimensions = true
local result2 = luakeys.parse('dim=1cm') -- { dim = 1234567 }

it('result2', function()
  assert.is.same({ dim = 1234567 }, result2)
end)
