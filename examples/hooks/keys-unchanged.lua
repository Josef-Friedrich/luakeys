require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('l1={l2=1}', {
  hooks = {
    keys = function(key, value)
      return key, value
    end,
  },
})
luakeys.debug(result) -- { l1 = { l2 = 1 } }

it('result', function()
  assert.are.same(result, { l1 = { l2 = 1 } })
end)
