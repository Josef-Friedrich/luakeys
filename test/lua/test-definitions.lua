require('busted.runner')()

local luakeys = require('luakeys')

describe('Defintions', function()
  describe('Options', function()
    describe('Option “data_type”', function()
      local function assert_type(data_type, input_value, expected_value)
        assert.are.same({ key = expected_value },
          luakeys.parse('key=' .. tostring(input_value),
            { definitions = { key = { data_type = data_type } } }),
          data_type .. '; input: ' .. tostring(input_value) .. ' expected: ' ..
            tostring(expected_value))
      end

      it('should convert different input values into boolean', function()
        assert_type('boolean', 'test', true)
        assert_type('boolean', true, true)
        assert_type('boolean', false, false)
        assert_type('boolean', 0, false)
        assert_type('boolean', 1, true)
        assert_type('boolean', {}, true)
      end)

      it('should check input values if they are dimensions', function()
        assert_type('dimension', '1cm', '1cm')
        assert_type('dimension', '12 pt', '12 pt')
        assert.has_error(function()
          assert_type('dimension', 'xxx', '12 pt')
        end)
      end)

      it('should check input values if they are integer', function()
        assert_type('integer', '1', 1)
        assert_type('integer', 123, 123)
        assert_type('integer', 1.23, 1)
        assert_type('integer', -1, -1)
        assert.has_error(function()
          assert_type('integer', 'x', 'x')
        end)
      end)

      it('should check input values if they are number', function()
        assert_type('number', '1.23', 1.23)
        assert_type('number', 123, 123)
        assert_type('number', 1.23, 1.23)
        assert_type('number', -1, -1)
        assert.has_error(function()
          assert_type('number', 'x', 'x')
        end)
      end)

      it('should convert different input values into strings', function()
        assert_type('string', 'test', 'test')
        assert_type('string', 1, '1')
        assert_type('string', 1.23, '1.23')
        assert_type('string', true, 'true')
        assert_type('string', '1cm', '1cm')
      end)
    end)
  end)
end)
