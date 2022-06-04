require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({
  one = { default = 1 },
  two = { default = 2 },
  three = { default = 3 },
})
local result = parse('one,two,three') -- { one = 1, two = 2, three = 3 }

it('result', function()
  assert.are.same(result, { one = 1, two = 2, three = 3 })
end)
