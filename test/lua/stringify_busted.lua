require 'busted.runner'()

local luakeys = require('luakeys')
local stringify = luakeys.stringify

local function assert_equals(input, expected)
  assert.are.same(expected, stringify(input))
end

describe('Function stringify', function()
  it('integer indexes', function()
    assert_equals({'one'}, '{\n  [1] = \'one\',\n}')
  end)

  it('string indexes', function()
    assert_equals({['one'] = 1}, '{\n  [\'one\'] = 1,\n}')
  end)
end)
