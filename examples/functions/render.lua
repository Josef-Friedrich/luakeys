require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('one=1,two=2,three=3,')
local kv_string = luakeys.render(result)
--- one=1,two=2,tree=3,
--- or:
--- two=2,one=1,tree=3,
--- or:
--- ...

it('result', function()
  assert.is.same(result, { one = 1, two = 2, three = 3 })
end)

local result2 = luakeys.parse('one,two,three', { naked_as_value = true })
local kv_string2 = luakeys.render(result2) --- one,two,three, (always)

it('kv_string2', function()
  assert.is.same(kv_string2, 'one,two,three,')
end)
