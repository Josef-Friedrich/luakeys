require('busted.runner')()
local luakeys = require('luakeys')()

local result = luakeys.parse('x,d1={x,d2={x}}', {
  naked_as_value = true,
  unpack = false,
  hooks = {
    keys = function(key, value, depth)
      if value == 'x' then
        return key, depth
      end
      return key, value
    end,
  },
})
luakeys.debug(result) -- { 1, d1 = { 2, d2 = { 3 } } }

it('result', function()
  assert.are.same(result, { 1, d1 = { 2, d2 = { 3 } } })
end)
