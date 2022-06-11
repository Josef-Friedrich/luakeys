require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({
  'one',
  'two',
  key = {
    process = function(value, input, result, unknown)
      value = input.one + input.two
      result.one = nil
      result.two = nil
      return value
    end,
  },
})
local result = parse('key,one=1,two=2') -- { key = 3 }

it('result', function()
  assert.is.same({ key = 3 }, result)
end)
