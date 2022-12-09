require('busted.runner')()
local luakeys = require('luakeys')

describe('Options', function()
  it('Change default options', function()
    local defaults = luakeys.opts
    local old = defaults.convert_dimensions
    defaults.convert_dimensions = true
    assert.are.same({ 1234567 },
      luakeys.parse('1cm', { naked_as_value = true }))
    defaults.convert_dimensions = false
    assert.are.same({ '1cm' },
      luakeys.parse('1cm', { naked_as_value = true }))
    -- Restore
    defaults.convert_dimensions = old
  end)

  it('Unknown options should trigger an error message.', function()
    assert.has_error(function()
      luakeys.parse('key', { xxx = true })
    end, 'Unknown parse option: xxx!')
  end)

  it('with underscores', function()
    assert.are.same({ '1cm' }, luakeys.parse('1cm', {
      convert_dimensions = false,
      naked_as_value = true,
    }))
  end)

  describe('Option “convert_dimensions”', function()
    it('true', function()
      assert.are.same({ dim = 1234567 }, luakeys.parse('dim=1cm', {
        convert_dimensions = true,
      }))
    end)

    it('false', function()
      assert.are.same({ dim = '1cm' }, luakeys.parse('dim=1cm', {
        convert_dimensions = false,
      }))
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
                assert.are.same(pre_def,
                  { key = 'value', unknown = 'unknown' })
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
      assert.are.same(result_parse,
        { key = 'value', unknown = 'unknown' })
    end)
  end)

  describe('Option “default”', function()
    it('should give a naked key the value', function()
      assert.are.same({ naked = 1 },
        luakeys.parse('naked', { default = 1 }))
    end)

    it('should be true if no option is specifed', function()
      assert.are.same({ naked = true }, luakeys.parse('naked'))
    end)

    it('should prefer the default option for the key definitions.',
      function()
        assert.are.same({ naked = 2 }, luakeys.parse('naked', {
          default = 1,
          defs = { naked = { default = 2 } },
        }))
      end)

    it('should be used as the default value if using key definitions.',
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
      assert_defaults('key1=new',
        { key1 = 'default', key2 = 'default' },
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

  describe('Option “format_keys”', function()
    local function assert_format_keys(kv_string, styles, expected)
      assert.are.same(expected, luakeys.parse(kv_string,
        { format_keys = styles }))
    end

    describe('lower', function()
      it('default', function()
        assert_format_keys('TEST=Test', {}, { TEST = 'Test' })
      end)

      it('true', function()
        assert_format_keys('TEST=Test', { 'lower' }, { test = 'Test' })
      end)

      it('recursive', function()
        assert_format_keys('TEST1={TEST2={Test}}', { 'lower' },
          { test1 = { test2 = 'Test' } })
      end)
    end)

    describe('snake', function()
      it('Whitespaces', function()
        assert_format_keys('key   one=1', { 'snake' }, { key_one = 1 })
      end)

      it('special characters', function()
        assert_format_keys('löve=1', { 'snake' }, { l_ve = 1 })
      end)

      it('Numbers', function()
        assert_format_keys('1 2 3', { 'snake' }, { ['1_2_3'] = true })
      end)
    end)
  end)

  describe('Option “hooks”', function()
    it('Unknown hook', function()
      assert.has_error(function()
        luakeys.parse('', {
          hooks = {
            xxx = function()
            end,
          },
        })
      end, 'Unknown hook: xxx!')

    end)

    it('Hook “kv_string”', function()
      local result = luakeys.parse('key=unknown', {
        hooks = {
          kv_string = function(kv_string)
            return kv_string:gsub('unknown', 'value')
          end,
        },
      })
      assert.are.same(result, { key = 'value' })
    end)

    describe('Hook “keys_before_opts”', function()
      it('standalone string values as keys', function()
        local function keys_before_opts(key, value)
          if type(key) == 'number' and type(value) == 'string' then
            return value, 42
          end
          return key, value
        end

        assert.are.same(luakeys.parse('one,two,three={four}', {
          hooks = { keys_before_opts = keys_before_opts },
          naked_as_value = true,
        }), { one = 42, two = 42, three = { four = 42 } })
      end)

      it('case insensitive keys', function()
        assert.are.same(luakeys.parse('TEST=test', {
          hooks = {
            keys_before_opts = function(key, value)
              if type(key) == 'string' then
                return key:lower(), value
              end
              return key, value
            end,
          },
        }), { test = 'test' })
      end)
    end)

    describe('Hook “result”', function()
      it('should add keys.', function()
        local result = luakeys.parse('key=value', {
          hooks = {
            result = function(result)
              result['additional_key'] = 'value'
            end,
          },
        })

        assert.are.same(result,
          { additional_key = 'value', key = 'value' })
      end)
    end)

    describe('Hook “keys”', function()
      local function assert_hook(kv_string, hook, expected)
        assert.is.same(luakeys.parse(kv_string, {
          hooks = { keys = hook },
          naked_as_value = true,
          unpack = false,
        }), expected)
      end

      it('Change the value', function()
        local hook = function(key, value)
          if type(value) == 'number' then
            return key, value + 1
          end
          return key, value
        end
        assert_hook('1, 2, 3', hook, { 2, 3, 4 })
        assert_hook('l1 = { l2 = 1 }', hook, { l1 = { l2 = 2 } })
        assert_hook('', hook, {})
      end)

      it('Return nothing', function()
        assert_hook('l1={l2=1}', function(key, value)
        end, {})
      end)

      it('Return key and value unchanged', function()
        assert_hook('l1={l2=1}', function(key, value)
          return key, value
        end, { l1 = { l2 = 1 } })
      end)

      it('change keys', function()
        assert_hook('l1={l2=1}', function(key, value)
          return 'prefix_' .. key, value
        end, { prefix_l1 = { prefix_l2 = 1 } })
      end)

      it('depth', function()
        assert_hook('%,d1={%,d2={%}}', function(key, value, depth)
          if value == '%' then
            return key, depth
          end
          return key, value
        end, { 1, d1 = { 2, d2 = { 3 } } })
      end)
    end)
  end)

  describe('Option “naked_as_value”', function()
    it('default', function()
      assert.are.same({ one = true }, luakeys.parse('one'))
    end)

    it('true', function()
      assert.are.same({ one = true, two = true, three = true },
        luakeys.parse('one,two,three', { naked_as_value = false }))
    end)

    it('false', function()
      assert.are.same({ 'one', 'two', 'three' }, luakeys.parse(
        'one,two,three', { naked_as_value = true }))
    end)
  end)

  describe('Option “no_error”', function()
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
      assert.are.same({ key = 1 },
        luakeys.parse('key={1}', options_true))
      assert.are.same({ key = { 1 } },
        luakeys.parse('key={1}', options_false))
    end)

    it('Not unpacked: two values', function()
      assert.is.same({ key = { one = true, two = true } },
        luakeys.parse('key={one,two}', options_true))
      assert.is.same({ key = { one = true, two = true } },
        luakeys.parse('key={one,two}', options_false))
    end)

    it('Not unpacked: nested table', function()
      assert.is.same({ one = true },
        luakeys.parse('{{one}}', options_true))
      assert.is.same({ { { one = true } } },
        luakeys.parse('{{one}}', options_false))
    end)
  end)

  it('Option “group_begin”', function()
    assert.is.same({ l1 = { key = 'value' } }, luakeys.parse(
      'l1 = ( key = value }', { group_begin = '(' }))
  end)

  it('Option “group_end”', function()
    assert.is.same({ l1 = { key = 'value' } }, luakeys.parse(
      'l1 = { key = value )', { group_end = ')' }))
  end)

  it('Option “list_separator”', function()
    assert.is.same({ 'one', 'two', 'three' },
      luakeys.parse('one;two;three',
        { list_separator = ';', naked_as_value = true }))
  end)

  it('Option “assignment_operator”', function()
    assert.is.same({ key = 'value' }, luakeys.parse('key:=value', {
      assignment_operator = ':=',
    }))
  end)

  describe('Option “quotation_begin” and “quotation_end”',
    function()
      it('single quote', function()
        assert.is.same({ key = 'value1,value2' },
          luakeys.parse('key = \'value1,value2\'', {
            quotation_begin = '\'',
            quotation_end = '\'',
          }))
      end)

      it('two single quotes', function()
        assert.is.same({ key = 'value1,value2' },
          luakeys.parse('key = \'\'value1,value2\'\'', {
            quotation_begin = '\'\'',
            quotation_end = '\'\'',
          }))
      end)

      it('unicode', function()
        assert.is.same({ key = 'value1,\\”value2' },
          luakeys.parse('key = “value1,\\”value2”', {
            quotation_begin = '“',
            quotation_end = '”',
          }))
      end)
    end)

  it('Option “true_aliases” and “false_aliases”', function()
    assert.is.same({ ['true'] = true, ['false'] = false },
      luakeys.parse('true = on, false = off', {
        true_aliases = { 'on', 'yes' },
        false_aliases = { 'off', 'no' },
      }))
  end)

  describe('Option “invert_flag”', function()
    it('default', function()
      assert.is.same({ key1 = true, key2 = false },
        luakeys.parse('key1,!key2'))
    end)

    it('recursive example', function()
      assert.is.same({ l1 = { key1 = true, key2 = false } },
        luakeys.parse('l1={key1,!key2}', { invert_flag = '!' }))
    end)

    it('different symbol', function()
      assert.is.same({ key1 = true, key2 = false },
        luakeys.parse('key1,*key2', { invert_flag = '*' }))
    end)

    it('at the end', function()
      assert.is.same({ key1 = true, key2 = false },
        luakeys.parse('key1,key2*', { invert_flag = '*' }))
    end)

    it('invert false', function()
      assert.is.same({ key1 = false, key2 = true }, luakeys.parse(
        'key1,*key2', { invert_flag = '*', default = false }))
    end)
  end)

end)
