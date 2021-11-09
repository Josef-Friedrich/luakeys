require 'busted.runner'()

local luakeys = require('luakeys')

local assert_value = function(actual, expected)
  local result = luakeys.parse('key=' .. actual)
  local input = result.key
  assert.are.equal(expected, input)
end

describe('Lua number', function()
  it('Integer: 1', function()
    assert_value('1', 1)
  end)

  it('Integer with a plus sign: +1', function()
    assert_value('+1', 1)
  end)

  it('Integer with a minus sign: -1', function()
    assert_value('-1', -1)
  end)

  it('Floating point number: 1.1', function()
    assert_value('1.1', 1.1)
  end)

  it('Floating point number with a plus sign: +1.1', function()
    assert_value('+1.1', 1.1)
  end)

  it('11e-02', function()
    assert_value('11e-02', 11e-02)
  end)

  it('-11e-02', function()
    assert_value('-11e-02', -0.11)
  end)

  it('+11e-02', function()
    assert_value('+11e-02', 0.11)
  end)

  it('+ 11e-02', function()
    assert_value('+11e-02', 0.1)
  end)
end)

describe('Boolean', function()
  it('true', function()
    assert_value('true', true)
  end)

  it('TRUE', function()
    assert_value('TRUE', true)
  end)

  it('True', function()
    assert_value('True', true)
  end)

  it('false', function()
    assert_value('false', false)
  end)

  it('FALSE', function()
    assert_value('FALSE', false)
  end)

  it('False', function()
    assert_value('False', false)
  end)

  it('Not a boolean: 0', function()
    assert_value('0', 0)
  end)

  it('Not a boolean: 1', function()
    assert_value('1', 1)
  end)

  it('Not a boolean: truee', function()
    assert_value('truee', 'truee')
  end)
end)
