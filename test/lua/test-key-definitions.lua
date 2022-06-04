require('busted.runner')()

local luakeys

describe('Key defintions', function()
  setup(function()
    _G._TEST = true
    luakeys = require('luakeys')
  end)

  teardown(function()
    _G._TEST = nil
  end)

  describe('Function “apply_defintions()”', function()
    local apply_defintions = luakeys.apply_definitions

    describe('Name of the keys', function()
      local function get_input()
        return { key = 'value', unknown = 'unknown' }
      end

      it('can be given as stand-alone values.', function()
        assert.are.same(apply_defintions({ 'key' }, nil, get_input()),
          { key = 'value' })
      end)

      it('can be specified as keys in a Lua table.', function()
        local defintions = { key = {} }
        assert.are.same(apply_defintions(defintions, nil, get_input()),
          { key = 'value' })
      end)

      it('can be specified by the “name” option.', function()
        assert.are.same(
          apply_defintions({ { name = 'key' } }, nil, get_input()),
          { key = 'value' })
      end)
    end)

    describe('Options', function()

      describe('Option “alias”', function()
        local defintions = {
          key1 = { alias = 'k1' },
          key2 = { alias = { 'k2', 'my_key2' } },
        }

        it(
          'should find a value if the “alias” option is specified as a string and store it under the original key name.',
          function()
            assert.are.same(apply_defintions(defintions, nil, { k1 = 42 }),
              { key1 = 42 })
          end)

        it(
          'should find a value if the “alias” option is specified as an array of string and store it under the original key name.',
          function()
            assert.are.same(apply_defintions(defintions, nil,
              { ['my_key2'] = 42 }), { key2 = 42 })
          end)

        it('should find a alias standalone values as key names', function()
          assert.are.same(apply_defintions({ key = { alias = { 'k', 'ke' } } },
            nil, { 'ke' }), { key = true })
        end)

        it('should find a value in a nested definition', function()
          assert.are.same(apply_defintions({
            level1 = {
              alias = 'l1',
              sub_keys = { level2 = { alias = { 'l2', 'level_2' } } },
            },
          }, nil, { l1 = { l2 = 'value' } }), { level1 = { level2 = 'value' } })
        end)

        describe('Error messages', function()
          it('should throw an error if two aliases are present', function()
            assert.has_error(function()
              apply_defintions({ key = { alias = { 'k', 'ke' } } }, nil,
                { k = 'value', ke = 'value' })
            end, 'Duplicate aliases “k” and “ke” for key “key”!')
          end)

          it('should throw an error if the key and an alias are present',
            function()
              assert.has_error(function()
                apply_defintions({ key = { alias = { 'k', 'ke' } } }, nil,
                  { key = 'value', k = 'value' })
              end, 'Duplicate aliases “key” and “k” for key “key”!')
            end)
        end)

      end)

      describe('Option “always_present”', function()
        it('should pass an value to the key if the input is empty', function()
          assert.are.same(apply_defintions({ key = { always_present = true } },
            nil, {}), { key = true })
        end)

        it('should use the default value', function()
          assert.are.same(apply_defintions({
            key = { always_present = true, default = 'value' },
          }, nil, {}), { key = 'value' })
        end)

        it('should work in an nested definition', function()
          assert.are.same(apply_defintions({
            level1 = {
              sub_keys = { key = { always_present = true, default = 'value' } },
            },
          }, nil, {}), { level1 = { key = 'value' } })
        end)
      end)

      describe('Option “choices”', function()
        local defintions = { key = { choices = { 'one', 'two', 'three' } } }
        it('should throw no exception', function()
          assert.are.same(apply_defintions(defintions, nil, { key = 'one' }),
            { key = 'one' })
        end)

        it('should throw an exception if no choice was found.', function()
          assert.has_error(function()
            apply_defintions(defintions, nil, { key = 'unknown' })
          end,
            'The value “unknown” does not exist in the choices: one, two, three!')
        end)
      end)

      describe('Option “data_type”', function()
        local function assert_type(data_type, input_value, expected_value)
          assert.are.same(apply_defintions({ key = { data_type = data_type } },
            nil, { key = input_value }), { key = expected_value })
        end

        it('should convert different input values into strings', function()
          assert_type('string', 'test', 'test')
          assert_type('string', 0, '0')
          assert_type('string', false, 'false')
        end)

        it('should convert different input values into boolean', function()
          assert_type('boolean', 'test', true)
          assert_type('boolean', true, true)
          assert_type('boolean', false, false)
          assert_type('boolean', '', false)
          assert_type('boolean', 0, false)
          assert_type('boolean', 1, true)
          assert_type('boolean', {}, true)
        end)

        it('should check input values if they are dimensions', function()
          assert_type('dimension', '1cm', '1cm')
          assert_type('dimension', '12 pt', '12 pt')
          -- assert_type('dimension', 'xxx', '12 pt')
        end)

        it('should check input values if they are integer', function()
          assert_type('integer', '1', 1)
          assert_type('integer', 123, 123)
        end)
      end)

      describe('Option “exclusive_group”', function()
        local defintions = {
          k1 = { exclusive_group = 'group1' },
          k2 = { exclusive_group = 'group1' },
          k3 = { exclusive_group = 'group3' },
          k4 = { default = 'value' },
        }

        it(
          'should pass if only one key of the mutually exclusive group is present.',
          function()
            assert.are.same(apply_defintions(defintions, nil, { k1 = 'value' }),
              { k1 = 'value' })
          end)

        it(
          'should throw an error if only two keys of the mutually exclusive group are present.',
          function()
            assert.has_error(function()
              apply_defintions(defintions, nil, { k1 = 'value', k2 = 'value' },
                {})
            end,
              'The key “k1” belongs to a mutually exclusive group “group1” and the key “k2” is already present!')
          end)

        it('should let other keys untouched.', function()
          assert.are.same(apply_defintions(defintions, nil, { 'k4' }),
            { k4 = 'value' })
        end)

        it('two keys of two different exclusive groups should pass.', function()
          assert.are.same(apply_defintions(defintions, nil,
            { k1 = 'value', k3 = 'value' }), { k1 = 'value', k3 = 'value' })
        end)
      end)

      it('Option “match”', function()
        assert.are.same(apply_defintions({
          date = { match = '^%d%d%d%d%-%d%d%-%d%d$' },
        }, nil, { date = '1978-12-03' }), { date = '1978-12-03' })
      end)

      describe('Option “opposite_keys”', function()
        local defintions = {
          visibility = { opposite_keys = { [true] = 'show', [false] = 'hide' } },
        }

        it('should return true if a truthy string value is given.', function()
          assert.are.same(apply_defintions(defintions, nil, { 'show' }),
            { visibility = true })
        end)

        it('should return false if a falsy string is given.', function()
          assert.are.same(apply_defintions(defintions, nil, { 'hide' }),
            { visibility = false })
        end)

        it('should return an empty table if a unknown string value is given.',
          function()
            local output = {}
            apply_defintions(defintions, nil, { 'unknown' }, output)
            assert.are.same(output, {})
          end)
      end)

      it('Option “process”', function()
        assert.are.same(apply_defintions({
          width = {
            process = function(value)
              if type(value) == 'number' and value >= 0 and value <= 1 then
                return tostring(value) .. '\\linewidth'
              end
              return value
            end,
          },
        }, nil, { width = 0.5 }), { width = '0.5\\linewidth' })
      end)

      describe('Option “required”', function()
        it('should pass if a value is provided', function()
          assert.are.same(apply_defintions({ key = { required = true } }, nil,
            { key = 'value' }), { key = 'value' })
        end)

        it('should throw an error if the key is missing', function()
          assert.has_error(function()
            apply_defintions({ key = { required = true } },
              { unknown = 'value' })
          end)
        end)
      end)

      it('Option “sub_keys”', function()
        local result = luakeys.parse('level1={level2=value}', {
          definitions = { level1 = { sub_keys = { level2 = { default = 1 } } } },
        })
        assert.are.same(result, { level1 = { level2 = 'value' } })
      end)
    end)

    describe('Return values', function()
      describe('leftover', function()
        it('should be an empty table if all keys are defined', function()
          local result, leftover = apply_defintions({ 'key' }, nil,
            { key = 'value' })
          assert.are.same(leftover, {})
        end)

        it('should be an non-empty table if all keys are defined', function()
          local result, leftover = apply_defintions({ 'key' }, nil, {
            key = 'value',
            unknown = 'unknown',
          })
          assert.are.same(leftover, { unknown = 'unknown' })
        end)

        it('should be an non-empty table if all keys are defined', function()
          local result, leftover = apply_defintions({
            key1 = { sub_keys = { 'known1' } },
            key2 = { sub_keys = { 'known2' } },
          }, nil, {
            key1 = { known1 = 1, unknown1 = 1 },
            key2 = { known2 = 1, unknown2 = 1, unknown3 = 1 },
            unknown = 'unknown',
          })
          assert.are.same(leftover, {
            key1 = { unknown1 = 1 },
            key2 = { unknown2 = 1, unknown3 = 1 },
            unknown = 'unknown',
          })
        end)
      end)

    end)
  end)

  describe('Function “define()”', function()
    local define = luakeys.define

    local function define_parse(defintions, kv_string)
      local parse = define(defintions)
      return parse(kv_string, { no_error = true })
    end

    describe('Name of the keys', function()
      local kv_string = 'key=value,unknown=unknown'

      it('can be given as stand-alone values.', function()
        local result, leftover = define_parse({ 'key' }, kv_string)
        assert.are.same(result, { key = 'value' })
        assert.are.same(leftover, { unknown = 'unknown' })
      end)

      it('can be specified as keys in a Lua table.', function()
        local result, leftover = define_parse({ key = {} }, kv_string)
        assert.are.same(result, { key = 'value' })
        assert.are.same(leftover, { unknown = 'unknown' })
      end)

      it('can be specified by the “name” option.', function()
        local result, leftover = define_parse({ { name = 'key' } }, kv_string)
        assert.are.same(result, { key = 'value' })
        assert.are.same(leftover, { unknown = 'unknown' })
      end)

      it('can be specified in a nested example.', function()
        local result, leftover = define_parse({
          level1 = { sub_keys = { level2 = { sub_keys = { key = {} } } } },
        }, 'level1={level2={key=value,unknown=unknown}}')
        assert.are.same(result, { level1 = { level2 = { key = 'value' } } })
        assert.are.same(leftover,
          { level1 = { level2 = { unknown = 'unknown' } } })
      end)
    end)

    it('Return values: result and leftover', function()
      local parse = define({ { name = 'key1' } })
      local result, leftover = parse('key1=value1')
      assert.are.same(result, { key1 = 'value1' })
      assert.are.same(leftover, {})
    end)

    it('should merge inner default options', function()
      local parse = define({ 'key1', 'key2' })
      local result = parse('key1=value1', { defaults = { key2 = 'value2' } })
      assert.are.same(result, { key1 = 'value1', key2 = 'value2' })
    end)

    it('should merge outer default options', function()
      local parse = define({ 'key1', 'key2' },
        { defaults = { key2 = 'value2' } })
      local result = parse('key1=value1')
      assert.are.same(result, { key1 = 'value1', key2 = 'value2' })
    end)
  end)

end)
