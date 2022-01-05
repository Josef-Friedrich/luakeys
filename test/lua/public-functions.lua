require 'busted.runner'()

local luakeys = require('luakeys')

describe('Function “stringify()”', function()
  local function assert_equals(input, expected)
    assert.are.equal(expected, luakeys.stringify(input))
  end

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
    assert.are.equal('$\\{$\\par\\ \\ [1] = \'one\',\\par$\\}$',
                     luakeys.stringify({'one'}, true))
  end)
end)

describe('Function “render()”', function()
  local function assert_render(input, expected)
    assert.are.equal(expected, luakeys.render(luakeys.parse(input)))
  end

  it('standalone value as a string', function()
    assert_render('key', 'key,')
  end)

  it('standalone value as a number', function()
    assert_render('1', '1,')
  end)

  it('standalone value as a dimension', function()
    assert_render('1cm', '1234567,')
  end)

  it('standalone value as a boolean', function()
    assert_render('TRUE', 'true,')
  end)

  it('A list of standalone values', function()
    assert_render('one,two,three', 'one,two,three,')
  end)
end)

describe('Function “parse()”', function()
  local function assert_parse(input, expected)
    assert.are.same(expected, luakeys.parse(input))
  end

  describe('Options', function()
    describe('Option converter', function()
      it('standalone string values as keys', function()
        local function converter(key, value, depth, current_table, root_table)
          if type(key) == 'number' and type(value) == 'string' then
            return value, true
          end
          return key, value
        end

        assert.are.same(luakeys.parse('one,two,three', {converter = converter}),
                        {one = true, two = true, three = true})
      end)
    end)

    it('Change default options', function()
      local defaults = luakeys.default_options
      assert.are.same({1234567}, luakeys.parse('1cm'))
      defaults.convert_dimensions = false
      assert.are.same({'1cm'}, luakeys.parse('1cm'))
      -- Restore
      defaults.convert_dimensions = true
    end)

    it('with spaces', function()
      assert.are.same({'1cm'},
                      luakeys.parse('1cm', {['convert dimensions'] = false}))
    end)

    it('with underscores', function()
      assert.are.same({'1cm'},
                      luakeys.parse('1cm', {convert_dimensions = false}))
    end)

    describe('convert dimensions', function()
      it('true', function()
        assert.are.same({1234567},
                        luakeys.parse('1cm', {['convert dimensions'] = true}))
      end)

      it('false', function()
        assert.are.same({'1cm'},
                        luakeys.parse('1cm', {['convert dimensions'] = false}))
      end)
    end)
  end)

  describe('Whitespaces', function()
    it('No whitepsaces', function()
      assert_parse('integer=1', {integer = 1})
    end)

    it('With whitespaces', function()
      assert_parse('integer = 2', {integer = 2})
    end)

    it('With tabs', function()
      assert_parse('integer\t=\t3', {integer = 3})
    end)

    it('With newlines', function()
      assert_parse('integer\n=\n4', {integer = 4})
    end)

    it('With whitespaces, tabs and newlines', function()
      assert_parse('integer \t\n= \t\n5 , boolean=false',
                   {integer = 5, boolean = false})
    end)

    it('Two keys with whitespaces', function()
      assert_parse('integer=1 , boolean=false', {integer = 1, boolean = false})
    end)

    it('Two keys with whitespaces, tabs, newlines', function()
      assert_parse('integer \t\n= \t\n1 \t\n, \t\nboolean \t\n= \t\nfalse',
                   {integer = 1, boolean = false})
    end)
  end)

  describe('Multiple keys', function()
    assert_parse('integer=1,boolean=false', {integer = 1, boolean = false})
    assert_parse('integer=1 , boolean=false', {integer = 1, boolean = false})
  end)

  describe('Edge cases', function()
    it('Empty string', function()
      assert_parse('', {})
    end)

    it('Only commas', function()
      assert_parse(',,', {})
    end)

    it('More commas', function()
      assert_parse(',,,', {})
    end)

    it('Commas with whitespaces', function()
      assert_parse(', , ,', {})
    end)

    it('Whitespace, comma', function()
      assert_parse(' ,', {})
    end)

    it('Comma, whitespace', function()
      assert_parse(', ', {})
    end)
  end)

  describe('Duplicate keys', function()
    it('Without whitespaces', function()
      assert_parse('integer=1,integer=2', {integer = 2})
    end)

    it('With whitespaces', function()
      assert_parse('integer=1 , integer=2', {integer = 2})
    end)
  end)

  describe('All features', function()
    it('List of standalone strings', function()
      assert_parse('one,two,three', {'one', 'two', 'three'})
    end)

    it('List of standalone integers', function()
      assert_parse('1,2,3', {1, 2, 3})
    end)

    it('Nested tables', function()
      assert_parse('level1={level2={level3=level3}}',
                   {level1 = {level2 = {level3 = 'level3'}}})
    end)

    it('String without quotes', function()
      assert_parse('string = without \'quotes\'',
                   {string = "without \'quotes\'"})
    end)

    it('String with quotes', function()
      assert_parse('string = "with quotes: ,={}"',
                   {string = 'with quotes: ,={}'})
    end)

    it('Negative number', function()
      assert_parse('number = -0.123', {number = -0.123})
    end)
  end)

  describe('Array', function()
    it('Key with nested tables', function()
      assert_parse('t={a,b},z={{a,b},{c,d}}',
                   {t = {'a', 'b'}, z = {{'a', 'b'}, {'c', 'd'}}})
    end)

    it('Nested list of strings', function()
      assert_parse('{one,two,tree}', {{'one', 'two', 'tree'}})
    end)

    it('standalone and key value pair', function()
      assert_parse('{one,two,tree={four}}', {{'one', 'two', tree = 'four'}})
    end)

    it('Deeply nested string value', function()
      assert_parse('{{{one}}}', {{{'one'}}})
    end)
  end)

  describe('Only values', function()
    it('List of mixed values', function()
      assert_parse('-1.1,text,-1cm,True', {-1.1, 'text', 1234567, true})
    end)

    it('Only string values', function()
      assert_parse('one,two,three', {'one', 'two', 'three'})
    end)
  end)
end)

describe('Functions “save()” and “get()”', function()
  it('Save and get with an existent identifier', function()
    luakeys.save('test123', 'Some value')
    assert.is.equal(luakeys.get('test123'), 'Some value')
  end)

  it('Throws error #skip', function()
    assert.has_error(function()
      luakeys.get('xxx')
    end, 'No stored result was found for the identifier \'xxx\'')
  end)
end)
