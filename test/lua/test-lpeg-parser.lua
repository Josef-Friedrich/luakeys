require('busted.runner')()

local luakeys = require('luakeys')

local function assert_result(kv_string, expected, opts)
  assert.are.same(expected, luakeys.parse(kv_string, opts))
end

local function assert_value(actual, expected)
  local result = luakeys.parse('key=' .. actual)
  local input = result.key
  assert.are.equal(expected, input)
end

describe('LPeg Parser', function()
  describe('Lua number', function()
    it('Integer', function()
      assert_value('1', 1)
    end)

    it('Integer with leading zeros', function()
      assert_value('0001', 1)
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
      local result = luakeys.parse('key=' .. actual,
        { convert_dimensions = true })
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
      local result = luakeys.parse('key=' .. actual,
        { convert_dimensions = true })
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

      it(
        'Whitespace und Number followed by a string is a string: “ 1 test”',
        function()
          assert_type(' 1 test ', 'string')
        end)

      it('Number followed by a string is a string: “ 1 test”', function()
        assert_type('1 test', 'string')
      end)
    end)

    describe('Keys', function()
      it('Simple string', function()
        assert_result('key=1', { key = 1 })
      end)

      it('string: Umlaute', function()
        assert_result('umlaute öäü=1', { ['umlaute öäü'] = 1 })
      end)

      it('string: underscore: “under_score=1”', function()
        assert_result('under_score=1', { under_score = 1 })
      end)

      it('number: “2=2”', function()
        assert_result('2=2', { [2] = 2 })
      end)

      it('number: “1=a,b”', function()
        assert_result('1=a,b', { 'a', 'b' }, { naked_as_value = true })
      end)
    end)
  end)

  describe('Nested', function()
    it('single value nested', function()
      assert.are.same({ key = { 1 } },
        luakeys.parse('key={1}', { unpack = false }))
    end)
  end)
end)

describe('Whitespaces', function()
  it('No whitepsaces', function()
    assert_result('integer=1', { integer = 1 })
  end)

  it('With whitespaces', function()
    assert_result('integer = 2', { integer = 2 })
  end)

  it('With tabs', function()
    assert_result('integer\t=\t3', { integer = 3 })
  end)

  it('With newlines', function()
    assert_result('integer\n=\n4', { integer = 4 })
  end)

  it('With whitespaces, tabs and newlines', function()
    assert_result('integer \t\n= \t\n5 , boolean=false',
      { integer = 5, boolean = false })
  end)

  it('Two keys with whitespaces', function()
    assert_result('integer=1 , boolean=false', { integer = 1, boolean = false })
  end)

  it('Two keys with whitespaces, tabs, newlines', function()
    assert_result('integer \t\n= \t\n1 \t\n, \t\nboolean \t\n= \t\nfalse',
      { integer = 1, boolean = false })
  end)
end)

describe('Multiple keys', function()
  assert_result('integer=1,boolean=false', { integer = 1, boolean = false })
  assert_result('integer=1 , boolean=false', { integer = 1, boolean = false })
end)

describe('Edge cases', function()
  it('Empty string', function()
    assert_result('', {})
  end)

  it('Only commas', function()
    assert_result(',,', {})
  end)

  it('More commas', function()
    assert_result(',,,', {})
  end)

  it('Commas with whitespaces', function()
    assert_result(', , ,', {})
  end)

  it('Whitespace, comma', function()
    assert_result(' ,', {})
  end)

  it('Comma, whitespace', function()
    assert_result(', ', {})
  end)
end)

describe('Duplicate keys', function()
  it('Without whitespaces', function()
    assert_result('integer=1,integer=2', { integer = 2 })
  end)

  it('With whitespaces', function()
    assert_result('integer=1 , integer=2', { integer = 2 })
  end)
end)

describe('All features', function()
  it('List of standalone strings', function()
    assert_result('one,two,three', { 'one', 'two', 'three' },
      { naked_as_value = true })
  end)

  it('List of standalone integers', function()
    assert_result('1,2,3', { 1, 2, 3 })
  end)

  it('Nested tables', function()
    assert_result('level1={level2={level3=level3}}',
      { level1 = { level2 = { level3 = 'level3' } } })
  end)

  it('String without quotes', function()
    assert_result('string = without \'quotes\'',
      { string = 'without \'quotes\'' })
  end)

  it('String with quotes', function()
    assert_result('string = "with quotes: ,={}"',
      { string = 'with quotes: ,={}' })
  end)

  it('Negative number', function()
    assert_result('number = -0.123', { number = -0.123 })
  end)
end)

describe('Array', function()
  it('Key with nested tables', function()
    assert_result('t={a,b},z={{a,b},{c,d}}',
      { t = { 'a', 'b' }, z = { { 'a', 'b' }, { 'c', 'd' } } },
      { naked_as_value = true })
  end)

  it('Nested list of strings', function()
    assert_result('{one,two,tree}', { { 'one', 'two', 'tree' } },
      { naked_as_value = true })
  end)

  it('standalone and key value pair', function()
    assert_result('{one,two,tree={four}}', { { 'one', 'two', tree = 'four' } },
      { naked_as_value = true })
  end)

  it('Deeply nested string value', function()
    assert_result('{{{one}}}', { { { { 'one' } } } },
      { unpack = false, naked_as_value = true })
  end)
end)

describe('Only values', function()
  it('List of mixed values', function()
    assert_result('-1.1,text,-1cm,True', { -1.1, 'text', '-1cm', true },
      { naked_as_value = true })
  end)

  it('Only string values', function()
    assert_result('one,two,three', { 'one', 'two', 'three' },
      { naked_as_value = true })
  end)
end)
