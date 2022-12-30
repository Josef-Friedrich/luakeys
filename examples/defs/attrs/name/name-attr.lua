require('busted.runner')()
local luakeys = require('luakeys')()

local parse = luakeys.define({
  { name = 'one', default = 1 },
  { name = 'two', default = 2 },
})
local result = parse('one,two') -- { one = 1, two = 2 }

it('result', function()
  assert.is.same({ one = 1, two = 2 }, result)
end)
