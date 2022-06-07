require('busted.runner')()

local luakeys = require('luakeys')

describe('Defintions', function()
  describe('Attributes', function()
    describe('Attribute “case_insensitive_keys”', function()
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

    describe('Attribute “convert_dimensions”', function()
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

    describe('Attribute “data_type”', function()
      local function assert_data_type(data_type,
        input_value,
        expected_value)
        assert.are.same({ key = expected_value },
          luakeys.parse('key=' .. tostring(input_value),
            { definitions = { key = { data_type = data_type } } }),
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
        assert.are.same(expected, luakeys.parse(input_kv_string,
          { definitions = defintions }))
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
