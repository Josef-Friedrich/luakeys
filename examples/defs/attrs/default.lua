require('busted.runner')()
local luakeys = require('luakeys')()

local parse = luakeys.define({
  one = {},
  two = { default = 2 },
  three = { default = 3 },
}, { default = 1, defaults = { four = 4 } })
local result = parse('one,two,three') -- { one = 1, two = 2, three = 3, four = 4 }

it('result', function()
  assert.are.same(result, { one = 1, two = 2, three = 3, four = 4 })
end)
