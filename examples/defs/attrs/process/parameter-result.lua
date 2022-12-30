require('busted.runner')()
local luakeys = require('luakeys')()

local parse = luakeys.define({
  key = {
    process = function(value, input, result, unknown)
      result.additional_key = true
      return value
    end,
  },
})
local result = parse('key=1') -- { key = 1, additional_key = true }

it('result', function()
  assert.is.same({ key = 1, additional_key = true }, result)
end)
