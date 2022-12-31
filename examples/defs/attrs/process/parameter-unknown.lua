require('busted.runner')()
local luakeys = require('luakeys')()

local parse = luakeys.define({
  key = {
    process = function(value, input, result, unknown)
      unknown.unknown_key = true
      return value
    end,
  },
})

it('Error message', function()
  assert.has_error(function()
    parse('key=1') -- throws error message: 'luakeys error [E019]: Unknown keys: “unknown_key=true,”'
  end, 'luakeys error [E019]: Unknown keys: “unknown_key=true,”')
end)
