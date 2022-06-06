require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({
  one = {},
  two = { default = 2 },
  three = { default = 3 },
}, { default = 1 })
local result = parse('one,two,three') -- { one = 1, two = 2, three = 3 }

it('result', function()
  assert.are.same(result, { one = 1, two = 2, three = 3 })
end)
