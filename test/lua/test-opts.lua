require('busted.runner')()
local luakeys = require('luakeys')

describe('Options', function()

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

  describe('Option “defs”', function()
    it('should return three return tables', function()
      local result, result_unknown, result_parse =
        luakeys.parse('key', { defs = { key = { default = 'value' } } })
      assert.are.same(result, { key = 'value' })
      assert.are.same(result_unknown, {})
      assert.are.same(result_parse, { 'key' })
    end)

    it('all arguments of process callback', function()
      local result, result_unknown, result_parse = luakeys.parse(
        'key=value,unknown=unknown', {
          defs = {
            key = {
              process = function(value, pre_def, result, unknown)
                assert.are.same(pre_def, { key = 'value', unknown = 'unknown' })
                result.new_key = 'result'
                unknown.new_unknown = 'unknown'
                return value
              end,
            },
          },
          no_error = true,
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
        defs = { naked = { default = 2 } },
      }))
    end)

    it('should be used as the default value if using key defintions.',
      function()
        assert.are.same({ naked = 1 }, luakeys.parse('naked', {
          default = 1,
          defs = { naked = {} },
        }))
      end)
  end)

  describe('Option “defaults”', function()
    local function assert_defaults(kv_string, defaults, expected)
      assert.are.same(luakeys.parse(kv_string, {
        defaults = defaults,
        naked_as_value = true,
      }), expected)
    end

    it('Should add a default key.', function()
      assert_defaults('key1=new', { key1 = 'default', key2 = 'default' },
        { key1 = 'new', key2 = 'default' })
    end)

    it('Should not overwrite an existing value', function()
      assert_defaults('key=new', { key = 'old' }, { key = 'new' })
    end)

    it('Should work in a nested table', function()
      assert_defaults('level1={level2={key1=new}}', {
        level1 = { level2 = { key1 = 'default', key2 = 'default' } },
      }, { level1 = { level2 = { key1 = 'new', key2 = 'default' } } })
    end)

    it('Should not merge arrays, integer indexed values.', function()
      assert_defaults('a,b', { 'c', 'd' }, { 'a', 'b' })
    end)

    it('Should be able to merge empty defaults.', function()
      assert_defaults('a,b', {}, { 'a', 'b' })
    end)

    it('Should be able to merge empty targets.', function()
      assert_defaults('', { 'c', 'd' }, { 'c', 'd' })
    end)

    it('Should join the keys.', function()
      assert_defaults('a=A', { b = 'B' }, { a = 'A', b = 'B' })
    end)

    it('Should join the keys of nested tables.', function()
      assert_defaults('a=A,b={c=C}', { b = { d = 'D' } },
        { a = 'A', b = { c = 'C', d = 'D' } })
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
      assert.are.same({ 'one', 'two', 'three' },
        luakeys.parse('one,two,three', { naked_as_value = true }))
    end)
  end)

  describe('Option “no_error”', function()
    local warn_unknown_keys = luakeys.warn_unknown_keys
    it('A definied key should throw no error.', function()
      luakeys.parse('key', { defs = { 'key' } })
    end)

    it('An non-empty unkown table should throw an error.', function()
      assert.has_error(function()
        luakeys.parse('unknown', { defs = { 'key' } })
      end, 'Unknown keys: unknown,')
    end)

    it('should prevent an error.', function()
      luakeys.parse('unknown', { defs = { 'key' }, no_error = true })
    end)
  end)

  describe('Option “unpack”', function()
    local options_true = { unpack = true }
    local options_false = { unpack = false }

    it('unpacked: single string', function()
      assert.is.same({ key = 'string' },
        luakeys.parse('key={string}', options_true))
      assert.is.same({ key = { string = true } },
        luakeys.parse('key={string}', options_false))
    end)

    it('unpacked: single number', function()
      assert.are.same({ key = 1 }, luakeys.parse('key={1}', options_true))
      assert.are.same({ key = { 1 } }, luakeys.parse('key={1}', options_false))
    end)

    it('Not unpacked: two values', function()
      assert.is.same({ key = { one = true, two = true } },
        luakeys.parse('key={one,two}', options_true))
      assert.is.same({ key = { one = true, two = true } },
        luakeys.parse('key={one,two}', options_false))
    end)

    it('Not unpacked: nested table', function()
      assert.is.same({ one = true }, luakeys.parse('{{one}}', options_true))
      assert.is.same({ { { one = true } } },
        luakeys.parse('{{one}}', options_false))
    end)
  end)

end)
