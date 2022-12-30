require('busted.runner')()
local luakeys = require('luakeys')()

local v = luakeys.version
local version_string = v[1] .. '.' .. v[2] .. '.' .. v[3]
print(version_string) -- 0.7.0

if v[1] >= 1 and v[2] > 2 then
  print('You are using the right version.')
end

it('result', function ()
  assert.is.same(type(version_string), 'string')
  assert.is.same(type(v[1]), 'number')
  assert.is.same(type(v[2]), 'number')
  assert.is.same(type(v[3]), 'number')
end)
