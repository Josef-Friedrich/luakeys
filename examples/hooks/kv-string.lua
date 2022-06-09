require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('key=unknown', {
  hooks = {
    kv_string = function(kv_string)
      return kv_string:gsub('unknown', 'value')
    end,
  },
})
luakeys.debug(result) -- { key = 'value' }

it('result', function()
  assert.are.same(result, { key = 'value' })
end)
