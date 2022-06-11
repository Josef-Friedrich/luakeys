require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({
  key = {
    process = function(value, input, result, unknown)
      if type(value) == 'number' then
        return value + 1
      end
      return value
    end,
  },
})
local result = parse('key=1') -- { key = 2 }

it('result', function()
  assert.is.same({ key = 2 }, result)
end)
