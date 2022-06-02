require('busted.runner')()
local luakeys = require('luakeys')

local parse1 = luakeys.define({ one = { default = 1 }, two = { default = 2 } })
local result1 = parse1('one,two') -- { one = 1, two = 2 }

it('result', function()
  assert.is.same({ one = 1, two = 2 }, result1)
end)

local parse2 = luakeys.define({
  { name = 'one', default = 1 },
  { name = 'two', default = 2 },
})
local result2 = parse2('one,two') -- { one = 1, two = 2 }

it('result', function()
  assert.is.same({ one = 1, two = 2 }, result2)
end)
