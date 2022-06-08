require('busted.runner')()

local luakeys = require('luakeys')

describe('Defintions', function()
  describe('Attributes', function()
    describe('Attribute “alias”', function()
      local defintions = {
        key1 = { alias = 'k1' },
        key2 = { alias = { 'k2', 'my_key2' } },
      }
      local function assert_alias(kv_string, expected, defs)
        if defs == nil then
          defs = defintions
        end
        assert.are.same(expected, luakeys.parse(kv_string, { defs = defs }))
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

      it('should find a alias standalone values as key names', function()
        assert_alias('ke', { key = true }, { key = { alias = { 'k', 'ke' } } })
      end)

      it('should find a value in a nested definition', function()
        assert_alias('l1 = { l2 = value } }', { level1 = { level2 = 'value' } },
          {
            level1 = {
              alias = 'l1',
              sub_keys = { level2 = { alias = { 'l2', 'level_2' } } },
            },
          })
      end)

      describe('Error messages', function()
        it('should throw an error if two aliases are present', function()
          assert.has_error(function()
            assert_alias('k = value, ke = value', {},
              { key = { alias = { 'k', 'ke' } } })
          end, 'Duplicate aliases “k” and “ke” for key “key”!')
        end)

        it('should throw an error if the key and an alias are present',
          function()
            assert.has_error(function()
              assert_alias('key = value, k = value', {},
                { key = { alias = { 'k', 'ke' } } })
            end, 'Duplicate aliases “key” and “k” for key “key”!')
          end)
      end)
    end)

    describe('Attribute “choices”', function()
      local defintions = { key = { choices = { 'one', 'two', 'three' } } }

      it('should throw no exception', function()
        assert.are.same(luakeys.parse('key = one', { defs = defintions }),
          { key = 'one' })
      end)

      it('should throw an exception if no choice was found.', function()
        assert.has_error(function()
          luakeys.parse('key = unknown', { defs = defintions })
        end,
          'The value “unknown” does not exist in the choices: one, two, three!')
      end)
    end)

    describe('Attribute “data_type”', function()
      local function assert_data_type(data_type,
        input_value,
        expected_value)
        assert.are.same({ key = expected_value },
          luakeys.parse('key=' .. tostring(input_value),
            { defs = { key = { data_type = data_type } } }),
          data_type .. '; input: ' .. tostring(input_value) .. ' expected: ' ..
            tostring(expected_value))
      end

      it('should convert different input values into boolean', function()
        assert_data_type('boolean', 'test', true)
        assert_data_type('boolean', true, true)
        assert_data_type('boolean', false, false)
        assert_data_type('boolean', 0, false)
        assert_data_type('boolean', 1, true)
        assert_data_type('boolean', {}, true)
      end)

      it('should check input values if they are dimensions', function()
        assert_data_type('dimension', '1cm', '1cm')
        assert_data_type('dimension', '12 pt', '12 pt')
        assert.has_error(function()
          assert_data_type('dimension', 'xxx', '12 pt')
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

      it('should convert different input values into strings', function()
        assert_data_type('string', 'test', 'test')
        assert_data_type('string', 1, '1')
        assert_data_type('string', 1.23, '1.23')
        assert_data_type('string', true, 'true')
        assert_data_type('string', '1cm', '1cm')
      end)
    end)

    describe('Attribute “exclusive_group”', function()
      local defintions = {
        k1 = { exclusive_group = 'group1' },
        k2 = { exclusive_group = 'group1' },
        k3 = { exclusive_group = 'group3' },
        k4 = { default = 'value' },
      }

      local function assert_exclusive_group(input_kv_string,
        expected)
        assert.are.same(expected,
          luakeys.parse(input_kv_string, { defs = defintions }))
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

      it('two keys of two different exclusive groups should pass.', function()
        assert_exclusive_group('k1=value,k3=value',
          { k1 = 'value', k3 = 'value' })
      end)
    end)

  end)
end)
