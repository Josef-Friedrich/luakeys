require('busted.runner')()
local luakeys = require('luakeys')()

local parse = luakeys.define({ one = { default = 1 }, two = { default = 2 } })
local result = parse('one,two') -- { one = 1, two = 2 }

it('result', function()
  assert.are.same({ one = 1, two = 2 }, result)
end)

local result2 = luakeys.parse('one,two', {
  defs = { one = { default = 1 }, two = { default = 2 } },
}) -- { one = 1, two = 2 }

it('result2', function()
  assert.are.same({ one = 1, two = 2 }, result2)
end)
