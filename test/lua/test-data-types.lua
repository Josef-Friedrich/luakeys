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

  describe('Not-predicate', function()
    it('Not a boolean: truee', function()
      assert_value('truee', 'truee')
    end)

    it('Not a boolean: true e', function()
      assert_value('true e', 'true e')
    end)

    it('Not a boolean: falsee', function()
      assert_value('falsee', 'falsee')
    end)

    it('Not a boolean: false e', function()
      assert_value('false e', 'false e')
    end)

    it('Not a boolean: false e', function()
      assert_value('false 1', 'false 1')
    end)
  end)
end)

describe('String', function()
  it('A integer as string: "1"', function()
    assert_value('"1"', '1')
  end)

  it('Escape double quotes: "1\\\"test\\\"2"', function()
    assert_value('"1\\\"test\\\"2"', '1\\\"test\\\"2')
  end)

  it('Comma in a string: "1,2"', function()
    assert_value('"1,2"', '1,2')
  end)

  it('Curly braces: "1,2"', function()
    assert_value('"{}"', '{}')
  end)
end)

describe('Dimension', function()
  local function assert_dimension(actual)
    local result = luakeys.parse('key=' .. actual)
    assert.are.equal(result.key, 1234567)
  end

  it('1cm', function()
    assert_dimension('1cm')
  end)

  it('Minus sign: -1cm', function()
    assert_dimension('-1cm')
  end)

  it('Puls sign: +1cm', function()
    assert_dimension('+1cm')
  end)

  it('Whitespace: 1 cm', function()
    assert_dimension('1 cm')
  end)

  it('Plus sign and whitespace: + 1 cm', function()
    assert_dimension('+ 1 cm')
  end)

  it('Minus sign and whitespace: - 1 cm', function()
    assert_dimension('- 1 cm')
  end)

  it('Uppercase letter: 1CM', function()
    assert_dimension('1CM')
  end)

  describe('Not-predicate', function()
    it('Dimension followed by string should be a string', function()
      assert_value('1cm x', '1cm x')
    end)

    it('Dimension followed by boolean should be a string', function()
      assert_value('1cm true', '1cm true')
    end)

    it('Dimension followed by number should be a string', function()
      assert_value('1cm 1', '1cm 1')
    end)
  end)
end)

describe('Type', function()
  local function assert_type(actual, expected_type)
    local result = luakeys.parse('key=' .. actual)
    assert.are.equal(expected_type, type(result.key))
  end

  describe('number', function()
    it('1', function()
      assert_type('1', 'number')
    end)

    it(' 1 ', function()
      assert_type(' 1 ', 'number')
    end)

    it('1.1', function()
      assert_type('1.1', 'number')
    end)

    it('1cm', function()
      assert_type('1cm', 'number')
    end)

    it('-1.4cm', function()
      assert_type('-1.4cm', 'number')
    end)

    it('-0.4pt', function()
      assert_type('-0.4pt', 'number')
    end)
  end)

  describe('boolean', function()
    it('true', function()
      assert_type('true', 'boolean')
    end)

    it('false', function()
      assert_type('false', 'boolean')
    end)

    it('FALSE', function()
      assert_type('FALSE', 'boolean')
    end)
  end)

  describe('string', function()
    it('"lol"', function()
      assert_type('"lol"', 'string')
    end)

    it('Whitespace und Number followed by a string is a string: “ 1 test”',
      function()
        assert_type(' 1 test ', 'string')
      end)

    it('Number followed by a string is a string: “ 1 test”', function()
      assert_type('1 test', 'string')
    end)
  end)

end)
