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

  it('nested', function()
    assert_equals({{1}}, '{\n  [1] = {\n    [1] = 1,\n  },\n}')
  end)

  it('option for_tex = true', function()
    assert.are.same('$\\{$\\par\\ \\ [1] = \'one\',\\par$\\}$', stringify({'one'}, true))
  end)
end)
