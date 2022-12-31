require('busted.runner')()

local luakeys = require('luakeys')()

describe('Defintions', function()
  it('should throw an error if there is an unknown attribute',
    function()
      assert.has_error(function()
        luakeys.parse('', { defs = { key = { xxx = true } } })
      end, 'luakeys error [E014]: Unknown definition attribute: “xxx”')
    end)

  describe('Name of the keys', function()
    local function assert_key_name(defs)
      assert.are.same(luakeys.parse('key=value,unknown=unknown',
        { defs = defs, no_error = true }), { key = 'value' })
    end

    it('can be given as stand-alone values.', function()
      assert_key_name({ 'key' })
    end)

    it('can be specified as keys in a Lua table.', function()
      assert_key_name({ key = {} })
    end)

    it('can be specified by the “name” option.', function()
      assert_key_name({ { name = 'key' } })
    end)

    it('can be specified in a nested example.', function()
      local result, unknown = luakeys.parse(
        'level1={level2={key=value,unknown=unknown}}', {
          defs = {
            level1 = {
              sub_keys = { level2 = { sub_keys = { key = {} } } },
            },
          },
          no_error = true,
        })
      assert.are.same(result,
        { level1 = { level2 = { key = 'value' } } })
      assert.are.same(unknown,
        { level1 = { level2 = { unknown = 'unknown' } } })
    end)
  end)

  describe('Attributes', function()
    describe('Attribute “alias”', function()
      local definitions = {
        key1 = { alias = 'k1' },
        key2 = { alias = { 'k2', 'my_key2' } },
      }
      local function assert_alias(kv_string, expected, defs)
        if defs == nil then
          defs = definitions
        end
        assert.are.same(expected,
          luakeys.parse(kv_string, { defs = defs }))
      end

      it(
        'should find a value if the “alias” option is specified as a string and store it under the original key name.',
        function()
          assert_alias('k1 = 42', { key1 = 42 })
        end)

      it(
        'should find a value if the “alias” option is specified as an array of string and store it under the original key name.',
        function()
          assert_alias('my_key2=42', { key2 = 42 })
        end)

      it('should find a alias standalone values as key names',
        function()
          assert_alias('ke', { key = true },
            { key = { alias = { 'k', 'ke' } } })
        end)

      it('should find a value in a nested definition', function()
        assert_alias('l1 = { l2 = value } }',
          { level1 = { level2 = 'value' } }, {
            level1 = {
              alias = 'l1',
              sub_keys = { level2 = { alias = { 'l2', 'level_2' } } },
            },
          })
      end)

      describe('Error messages', function()
        it('should throw an error if two aliases are present',
          function()
            assert.has_error(function()
              assert_alias('k = value, ke = value', {},
                { key = { alias = { 'k', 'ke' } } })
            end,
              'luakeys error [E003]: Duplicate aliases “k” and “ke” for key “key”!')
          end)

        it('should throw an error if the key and an alias are present',
          function()
            assert.has_error(function()
              assert_alias('key = value, k = value', {},
                { key = { alias = { 'k', 'ke' } } })
            end,
              'luakeys error [E003]: Duplicate aliases “key” and “k” for key “key”!')
          end)
      end)
    end)

    describe('Attribute “always_present”', function()
      it('should pass an value to the key if the input is empty',
        function()
          assert.are.same(luakeys.parse('', {
            defs = { key = { always_present = true } },
          }), { key = true })
        end)

      it('should use the default value', function()
        assert.are.same(luakeys.parse('', {
          defs = { key = { always_present = true, default = 'value' } },
        }), { key = 'value' })
      end)

      it('should work in an nested definition', function()
        assert.are.same(luakeys.parse('', {
          defs = {
            level1 = {
              sub_keys = {
                key = { always_present = true, default = 'value' },
              },
            },
          },
        }), { level1 = { key = 'value' } })
      end)
    end)

    describe('Attribute “choices”', function()
      local defs = { key = { choices = { 'one', 'two', 'three' } } }

      it('should throw no exception', function()
        assert.are.same(luakeys.parse('key = one', { defs = defs }),
          { key = 'one' })
      end)

      it('should throw an exception if no choice was found.', function()
        assert.has_error(function()
          luakeys.parse('key = unknown', { defs = defs })
        end,
          'luakeys error [E004]: The value “unknown” does not exist in the choices: “one, two, three”')
      end)
    end)

    describe('Attribute “data_type”', function()
      local function assert_data_type(data_type,
        input_value,
        expected_value)
        assert.are.same({ key = expected_value },
          luakeys.parse('key=' .. tostring(input_value),
            { defs = { key = { data_type = data_type } } }),
          data_type .. '; input: ' .. tostring(input_value) ..
            ' expected: ' .. tostring(expected_value))
      end

      it('should convert different input values into boolean',
        function()
          assert_data_type('boolean', 'test', true)
          assert_data_type('boolean', true, true)
          assert_data_type('boolean', false, false)
          assert_data_type('boolean', 0, false)
          assert_data_type('boolean', 1, true)
          assert_data_type('boolean', {}, true)
        end)

      it('should check input values if they are dimensions', function()
        assert_data_type('dimension', '1cm', '1cm')
        assert_data_type('dimension', '12 pt', '12pt')
        assert.has_error(function()
          assert_data_type('dimension', 'xxx', '12pt')
        end)
      end)

      it('should check input values if they are integer', function()
        assert_data_type('integer', '1', 1)
        assert_data_type('integer', 123, 123)
        assert_data_type('integer', 1.23, 1)
        assert_data_type('integer', -1, -1)
        assert.has_error(function()
          assert_data_type('integer', 'x', 'x')
        end)
      end)

      it('should check input values if they are number', function()
        assert_data_type('number', '1.23', 1.23)
        assert_data_type('number', 123, 123)
        assert_data_type('number', 1.23, 1.23)
        assert_data_type('number', -1, -1)
        assert.has_error(function()
          assert_data_type('number', 'x', 'x')
        end)
      end)

      it('should convert different input values into strings',
        function()
          assert_data_type('string', 'test', 'test')
          assert_data_type('string', 1, '1')
          assert_data_type('string', 1.23, '1.23')
          assert_data_type('string', true, 'true')
          assert_data_type('string', '1cm', '1cm')
        end)
    end)

    describe('Attribute “exclusive_group”', function()
      local defs = {
        k1 = { exclusive_group = 'group1' },
        k2 = { exclusive_group = 'group1' },
        k3 = { exclusive_group = 'group3' },
        k4 = { default = 'value' },
      }

      local function assert_exclusive_group(input_kv_string,
        expected)
        assert.are.same(expected,
          luakeys.parse(input_kv_string, { defs = defs }))
      end

      it(
        'should pass if only one key of the mutually exclusive group is present.',
        function()
          assert_exclusive_group('k1=value', { k1 = 'value' })
        end)

      it(
        'should throw an error if two keys of the mutually exclusive group are present.',
        function()
          assert.has_error(function()
            assert_exclusive_group('k1=value,k2=value', {})
          end -- Flapping
          -- 'The key “k1” belongs to a mutually exclusive group “group1” and the key “k2” is already present!'
          )
        end)

      it('should let other keys untouched.', function()
        assert_exclusive_group('k4', { k4 = 'value' })
      end)

      it('two keys of two different exclusive groups should pass.',
        function()
          assert_exclusive_group('k1=value,k3=value',
            { k1 = 'value', k3 = 'value' })
        end)
    end)

    it('Attribute “match”', function()
      assert.are.same(luakeys.parse('date = 1978-12-03', {
        defs = { date = { match = '^%d%d%d%d%-%d%d%-%d%d$' } },
      }), { date = '1978-12-03' })
    end)

    describe('Attribute “opposite_keys”', function()
      local function assert_opposite_keys(kv_string, expected)
        assert.are.same(expected, luakeys.parse(kv_string, {
          no_error = true,
          defs = {
            visibility = {
              opposite_keys = { [true] = 'show', [false] = 'hide' },
            },
          },
        }))
      end

      it('should return true if a truthy string value is given.',
        function()
          assert_opposite_keys('show', { visibility = true })
        end)

      it('should return false if a falsy string is given.', function()
        assert_opposite_keys('hide', { visibility = false })
      end)

      it(
        'should return an empty table if a unknown string value is given.',
        function()
          assert_opposite_keys('unknown', {})
        end)
    end)

    describe('Attribute “pick”', function()
      local function assert_pick(pick_setting,
        expected_value,
        kv_string)
        if kv_string == nil then
          kv_string = 'first,false,1cm,1,1.23,"A string"'
        end
        assert.are.same(luakeys.parse(kv_string, {
          no_error = true,
          defs = { key = { pick = pick_setting } },
        }), { key = expected_value })
      end

      it('true', function()
        assert_pick(true, 'first')
      end)

      it('any', function()
        assert_pick('any', 'first')
      end)

      it('boolean', function()
        assert_pick('boolean', false)
      end)

      it('dimension', function()
        assert_pick('dimension', '1cm')
      end)

      it('integer', function()
        assert_pick('integer', 1)
      end)

      it('number', function()
        assert_pick('number', 1.23, '1.23,1')
      end)

      it('string', function()
        assert_pick('string', 'A string', '1,"A string"')
      end)

      it('Error: unknown data type', function()
        assert.has_error(function()
          luakeys.parse('key', { defs = { key = { pick = 'xxx' } } })
        end,
          'luakeys error [E011]: Wrong data type in the “pick” attribute: “xxx”. Allowed are: “any, boolean, dimension, integer, number, string”.')
      end)
    end)

    it('Attribute “process”', function()
      assert.are.same(luakeys.parse('width = 0.5', {
        defs = {
          width = {
            process = function(value)
              if type(value) == 'number' and value >= 0 and value <= 1 then
                return tostring(value) .. '\\linewidth'
              end
              return value
            end,
          },
        },
      }), { width = '0.5\\linewidth' })
    end)

    it('Attribute “process”', function()
      local parse = luakeys.define({
        tikz = {
          process = function(value, input, result, unknown)
            return luakeys.render(value)
          end,
        },
        foo = {},
        bar = {},
      })
      local options = parse(
        'foo={one=1, two=2}, bar=baz, tikz={scale=2, red}')
      assert.is.equal(type(options.tikz), 'string')
    end)

    describe('Attribute “required”', function()
      local defs = { key = { required = true } }
      it('should pass if a value is provided', function()
        assert.are.same(luakeys.parse('key=value', { defs = defs }),
          { key = 'value' })
      end)

      it('should throw an error if the key is missing', function()
        assert.has_error(function()
          luakeys.parse('unknown=value', { defs = defs })
        end)
      end)
    end)

    it('Attribute “sub_keys”', function()
      local result = luakeys.parse('level1={level2=value}', {
        defs = { level1 = { sub_keys = { level2 = { default = 1 } } } },
      })
      assert.are.same(result, { level1 = { level2 = 'value' } })
    end)

  end)
end)
