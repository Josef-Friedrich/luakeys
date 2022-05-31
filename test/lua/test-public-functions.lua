require 'busted.runner'()

local luakeys = require('luakeys')

describe('Function “stringify()”', function()
  local function assert_equals(input, expected)
    assert.are.equal(expected, luakeys.stringify(input))
  end

  it('integer indexes', function()
    assert_equals({ 'one' }, '{\n  [1] = \'one\',\n}')
  end)

  it('string indexes', function()
    assert_equals({ ['one'] = 1 }, '{\n  [\'one\'] = 1,\n}')
  end)

  it('nested', function()
    assert_equals({ { 1 } }, '{\n  [1] = {\n    [1] = 1,\n  },\n}')
  end)

  it('option for_tex = true', function()
    assert.are.equal('$\\{$\\par\\ \\ [1] = \'one\',\\par$\\}$',
      luakeys.stringify({ 'one' }, true))
  end)
end)

describe('Function “render()”', function()
  local function assert_render(input, expected)
    assert.are.equal(expected, luakeys.render(
      luakeys.parse(input, { naked_as_value = true })))
  end

  it('standalone value as a string', function()
    assert_render('key', 'key,')
  end)

  it('standalone value as a number', function()
    assert_render('1', '1,')
  end)

  it('standalone value as a dimension', function()
    assert_render('1cm', '1cm,')
  end)

  it('standalone value as a boolean', function()
    assert_render('TRUE', 'true,')
  end)

  it('A list of standalone values', function()
    assert_render('one,two,three', 'one,two,three,')
  end)
end)

describe('Function “parse()”', function()
  local function assert_parse(input, expected, opts)
    assert.are.same(expected, luakeys.parse(input, opts))
  end

  describe('Options', function()
    it('Change default options', function()
      local defaults = luakeys.default_options
      local old = defaults.convert_dimensions
      defaults.convert_dimensions = true
      assert.are.same({ 1234567 },
        luakeys.parse('1cm', { naked_as_value = true }))
      defaults.convert_dimensions = false
      assert.are
        .same({ '1cm' }, luakeys.parse('1cm', { naked_as_value = true }))
      -- Restore
      defaults.convert_dimensions = old
    end)

    it('with spaces', function()
      assert.are.same({ '1cm' }, luakeys.parse('1cm', {
        ['convert dimensions'] = false,
        naked_as_value = true,
      }))
    end)

    it('with underscores', function()
      assert.are.same({ '1cm' }, luakeys.parse('1cm', {
        convert_dimensions = false,
        naked_as_value = true,
      }))
    end)

    describe('Option “case_insensitive_keys”', function()
      it('default', function()
        assert.are.same({ TEST = 'Test' }, luakeys.parse('TEST=Test'))
      end)

      it('true', function()
        assert.are.same({ test = 'Test' }, luakeys.parse('TEST=Test', {
          case_insensitive_keys = true,
        }))
      end)

      it('recursive', function()
        assert.are.same({ test1 = { test2 = 'Test' } }, luakeys.parse(
          'TEST1={TEST2={Test}}', { case_insensitive_keys = true }))
      end)

      it('false', function()
        assert.are.same({ TEST = 'Test' }, luakeys.parse('TEST=Test', {
          case_insensitive_keys = false,
        }))
      end)
    end)

    describe('Option “convert_dimensions”', function()
      it('true', function()
        assert.are.same({ dim = 1234567 },
          luakeys.parse('dim=1cm', { convert_dimensions = true }))
      end)

      it('false', function()
        assert.are.same({ dim = '1cm' }, luakeys.parse('dim=1cm', {
          convert_dimensions = false,
        }))
      end)
    end)

    describe('Option “converter”', function()
      it('standalone string values as keys', function()
        local function converter(key, value)
          if type(key) == 'number' and type(value) == 'string' then
            return value, true
          end
          return key, value
        end

        assert.are.same(luakeys.parse('one,two,three={four}',
          { converter = converter }),
          { one = true, two = true, three = { four = true } })
      end)

      it('case insensitive keys', function()
        local function converter(key, value)
          if type(key) == 'string' then
            return key:lower(), value
          end
          return key, value
        end

        assert.are.same(luakeys.parse('TEST=test', { converter = converter }),
          { test = 'test' })
      end)
    end)

    describe('Option “definitions”', function()
      it('should return three return tables', function()
        local result, result_unknown, result_parse =
          luakeys.parse('key', { definitions = { key = { default = 'value' } } })
        assert.are.same(result, { key = 'value' })
        assert.are.same(result_unknown, {})
        assert.are.same(result_parse, { 'key' })
      end)

      it('all arguments of process callback', function()
        local result, result_unknown, result_parse = luakeys.parse(
          'key=value,unknown=unknown', {
            definitions = {
              key = {
                process = function(value, pre_def, result, unknown)
                  assert.are.same(pre_def,
                    { key = 'value', unknown = 'unknown' })
                  result.new_key = 'result'
                  unknown.new_unknown = 'unknown'
                  return value
                end,
              },
            },
          })
        assert.are.same(result, { key = 'value', new_key = 'result' })
        assert.are.same(result_unknown,
          { unknown = 'unknown', new_unknown = 'unknown' })
        assert.are.same(result_parse, { key = 'value', unknown = 'unknown' })
      end)
    end)

    describe('Option “default”', function()
      it('should give a naked key the value', function()
        assert.are.same({ naked = 1 }, luakeys.parse('naked', { default = 1 }))
      end)

      it('should be true if no option is specifed', function()
        assert.are.same({ naked = true }, luakeys.parse('naked'))
      end)

      it('should prefer the default option for the key defintions.', function()
        assert.are.same({ naked = 2 }, luakeys.parse('naked', {
          default = 1,
          definitions = { naked = { default = 2 } },
        }))
      end)

      it('should be used as the default value if using key defintions.',
        function()
          assert.are.same({ naked = 1 }, luakeys.parse('naked', {
            default = 1,
            definitions = { naked = {} },
          }))
        end)
    end)

    describe('Options “defaults”', function()
      it('Should add a default key.', function()
        assert.are.same(luakeys.parse('key1=new', {
          defaults = { key1 = 'default', key2 = 'default' },
        }), { key1 = 'new', key2 = 'default' })
      end)

      it('Should not overwrite an existing value', function()
        assert.are.same(
          luakeys.parse('key=new', { defaults = { key = 'old' } }),
          { key = 'new' })
      end)

      it('Should work in a nested table', function()
        assert.are.same(luakeys.parse('level1={level2={key1=new}}', {
          defaults = {
            level1 = { level2 = { key1 = 'default', key2 = 'default' } },
          },
        }), { level1 = { level2 = { key1 = 'new', key2 = 'default' } } })
      end)
    end)

    describe('Option “preprocess”', function()
      it('should add keys.', function()
        local result = luakeys.parse('key=value', {
          preprocess = function(result, kv_string)
            result['additional_key'] = 'value'
            result['kv_string'] = kv_string
          end,
        })

        assert.are.same(result, {
          additional_key = 'value',
          key = 'value',
          kv_string = 'key=value',
        })
      end)
    end)

    describe('Option “naked_as_value”', function()
      it('default', function()
        assert.are.same({ one = true }, luakeys.parse('one'))
      end)

      it('true', function()
        assert.are.same({ one = true, two = true, three = true }, luakeys.parse(
          'one,two,three', { naked_as_value = false }))
      end)

      it('false', function()
        assert.are.same({ 'one', 'two', 'three' }, luakeys.parse(
          'one,two,three', { naked_as_value = true }))
      end)
    end)

    describe('Option “unpack_single_valued_array”', function()
      local opts_true = { unpack_single_array_values = true }
      local opts_false = { unpack_single_array_values = false }

      it('unpacked: single string', function()
        assert.is.same({ key = 'string' },
          luakeys.parse('key={string}', opts_true))
        assert.is.same({ key = { string = true } },
          luakeys.parse('key={string}', opts_false))

      end)

      it('unpacked: single number', function()
        assert.are.same({ key = 1 }, luakeys.parse('key={1}', opts_true))
        assert.are.same({ key = { 1 } }, luakeys.parse('key={1}', opts_false))
      end)

      it('Not unpacked: two values', function()
        assert.is.same({ key = { one = true, two = true } },
          luakeys.parse('key={one,two}', opts_true))
        assert.is.same({ key = { one = true, two = true } },
          luakeys.parse('key={one,two}', opts_false))
      end)

      it('Not unpacked: nested table', function()
        assert.is.same({ one = true }, luakeys.parse('{{one}}', opts_true))
        assert.is.same({ { { one = true } } },
          luakeys.parse('{{one}}', opts_false))
      end)
    end)

  end)

  describe('Whitespaces', function()
    it('No whitepsaces', function()
      assert_parse('integer=1', { integer = 1 })
    end)

    it('With whitespaces', function()
      assert_parse('integer = 2', { integer = 2 })
    end)

    it('With tabs', function()
      assert_parse('integer\t=\t3', { integer = 3 })
    end)

    it('With newlines', function()
      assert_parse('integer\n=\n4', { integer = 4 })
    end)

    it('With whitespaces, tabs and newlines', function()
      assert_parse('integer \t\n= \t\n5 , boolean=false',
        { integer = 5, boolean = false })
    end)

    it('Two keys with whitespaces', function()
      assert_parse('integer=1 , boolean=false', { integer = 1, boolean = false })
    end)

    it('Two keys with whitespaces, tabs, newlines', function()
      assert_parse('integer \t\n= \t\n1 \t\n, \t\nboolean \t\n= \t\nfalse',
        { integer = 1, boolean = false })
    end)
  end)

  describe('Multiple keys', function()
    assert_parse('integer=1,boolean=false', { integer = 1, boolean = false })
    assert_parse('integer=1 , boolean=false', { integer = 1, boolean = false })
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
      assert_parse('integer=1,integer=2', { integer = 2 })
    end)

    it('With whitespaces', function()
      assert_parse('integer=1 , integer=2', { integer = 2 })
    end)
  end)

  describe('All features', function()
    it('List of standalone strings', function()
      assert_parse('one,two,three', { 'one', 'two', 'three' },
        { naked_as_value = true })
    end)

    it('List of standalone integers', function()
      assert_parse('1,2,3', { 1, 2, 3 })
    end)

    it('Nested tables', function()
      assert_parse('level1={level2={level3=level3}}',
        { level1 = { level2 = { level3 = 'level3' } } })
    end)

    it('String without quotes', function()
      assert_parse('string = without \'quotes\'',
        { string = 'without \'quotes\'' })
    end)

    it('String with quotes', function()
      assert_parse('string = "with quotes: ,={}"',
        { string = 'with quotes: ,={}' })
    end)

    it('Negative number', function()
      assert_parse('number = -0.123', { number = -0.123 })
    end)
  end)

  describe('Array', function()
    it('Key with nested tables', function()
      assert_parse('t={a,b},z={{a,b},{c,d}}',
        { t = { 'a', 'b' }, z = { { 'a', 'b' }, { 'c', 'd' } } },
        { naked_as_value = true })
    end)

    it('Nested list of strings', function()
      assert_parse('{one,two,tree}', { { 'one', 'two', 'tree' } },
        { naked_as_value = true })
    end)

    it('standalone and key value pair', function()
      assert_parse('{one,two,tree={four}}', { { 'one', 'two', tree = 'four' } },
        { naked_as_value = true })
    end)

    it('Deeply nested string value', function()
      assert_parse('{{{one}}}', { { { { 'one' } } } }, {
        unpack_single_array_values = false,
        naked_as_value = true,
      })
    end)
  end)

  describe('Only values', function()
    it('List of mixed values', function()
      assert_parse('-1.1,text,-1cm,True', { -1.1, 'text', '-1cm', true },
        { naked_as_value = true })
    end)

    it('Only string values', function()
      assert_parse('one,two,three', { 'one', 'two', 'three' },
        { naked_as_value = true })
    end)
  end)
end)

it('Function “debug()”', function()
  luakeys.debug({ key = 'value' })
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

describe('Function is.dimension', function()
  it('should return false', function()
    assert.is.equal(luakeys.is.dimension('xxx'), false)
  end)

  it('should return false if the input is nil', function()
    assert.is.equal(luakeys.is.dimension(), false)
  end)

  it('should return true', function()
    assert.is.equal(luakeys.is.dimension('1 cm'), true)
  end)
end)

describe('Function is.integer', function()
  it('should return false', function()
    assert.is.equal(luakeys.is.integer('1.1'), false)
  end)

  it('should return false if input is a string', function()
    assert.is.equal(luakeys.is.integer('xxx'), false)
  end)

  it('should return false if input is a integer', function()
    assert.is.equal(luakeys.is.integer(1), true)
  end)

  it('should return true', function()
    assert.is.equal(luakeys.is.integer('134'), true)
  end)
end)
