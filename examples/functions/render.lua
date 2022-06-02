require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('one=1,two=2,three=3,')
local kv_string = luakeys.render(result)
print(kv_string)
--- one=1,two=2,tree=3,
--- or:
--- two=2,one=1,tree=3,
--- or:
--- ...

it('result', function ()
  assert.is.same(result, { one = 1, two = 2, three = 3 })
end)
