require 'busted.runner'()

local luakeys = require('luakeys')

local parse = luakeys.parse

local function assert_deep_equals(actual, expected)
  assert.are.same(expected, parse(actual))
end

describe('Keys', function()
  it('Simple string', function()
    assert_deep_equals('key=1', {key = 1})
  end)

  it('string: Umlaute', function()
    assert_deep_equals('umlaute öäü=1', {["umlaute öäü"] = 1})
  end)

  it('string: underscore: “under_score=1”', function()
    assert_deep_equals('1=a,b', {'a', 'b'})
  end)

  it('number: “2=2”', function()
    assert_deep_equals('2=2', {[2] = 2})
  end)

  it('number: “1=a,b”', function()
    assert_deep_equals('1=a,b', {'a', 'b'})
  end)
end)
