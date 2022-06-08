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

  describe('Function “apply_definitions()”', function()
    local apply_definitions = luakeys.apply_definitions

    describe('Name of the keys', function()
      local function get_input()
        return { key = 'value', unknown = 'unknown' }
      end

      it('can be given as stand-alone values.', function()
        assert.are.same(apply_definitions({ 'key' }, nil, get_input()),
          { key = 'value' })
      end)

      it('can be specified as keys in a Lua table.', function()
        local defintions = { key = {} }
        assert.are.same(apply_definitions(defintions, nil, get_input()),
          { key = 'value' })
      end)

      it('can be specified by the “name” option.', function()
        assert.are.same(
          apply_definitions({ { name = 'key' } }, nil, get_input()),
          { key = 'value' })
      end)
    end)

    describe('Attributes', function()

      describe('Attribute “always_present”', function()
        it('should pass an value to the key if the input is empty', function()
          assert.are.same(
            apply_definitions({ key = { always_present = true } }, nil, {}),
            { key = true })
        end)

        it('should use the default value', function()
          assert.are.same(apply_definitions({
            key = { always_present = true, default = 'value' },
          }, nil, {}), { key = 'value' })
        end)

        it('should work in an nested definition', function()
          assert.are.same(apply_definitions({
            level1 = {
              sub_keys = { key = { always_present = true, default = 'value' } },
            },
          }, nil, {}), { level1 = { key = 'value' } })
        end)
      end)

      it('Attribute “match”', function()
        assert.are.same(apply_definitions({
          date = { match = '^%d%d%d%d%-%d%d%-%d%d$' },
        }, nil, { date = '1978-12-03' }), { date = '1978-12-03' })
      end)

      describe('Attribute “opposite_keys”', function()
        local defintions = {
          visibility = { opposite_keys = { [true] = 'show', [false] = 'hide' } },
        }

        it('should return true if a truthy string value is given.', function()
          assert.are.same(apply_definitions(defintions, nil, { 'show' }),
            { visibility = true })
        end)

        it('should return false if a falsy string is given.', function()
          assert.are.same(apply_definitions(defintions, nil, { 'hide' }),
            { visibility = false })
        end)

        it('should return an empty table if a unknown string value is given.',
          function()
            local output = {}
            apply_definitions(defintions, nil, { 'unknown' }, output)
            assert.are.same(output, {})
          end)
      end)

      it('Attribute “process”', function()
        assert.are.same(apply_definitions({
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

      describe('Attribute “required”', function()
        it('should pass if a value is provided', function()
          assert.are.same(apply_definitions({ key = { required = true } }, nil,
            { key = 'value' }), { key = 'value' })
        end)

        it('should throw an error if the key is missing', function()
          assert.has_error(function()
            apply_definitions({ key = { required = true } },
              { unknown = 'value' })
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

    describe('Return values', function()
      describe('unknown', function()
        it('should be an empty table if all keys are defined', function()
          local result, unknown = apply_definitions({ 'key' }, nil,
            { key = 'value' })
          assert.are.same(unknown, {})
        end)

        it('should be an non-empty table if all keys are defined', function()
          local result, unknown = apply_definitions({ 'key' }, nil, {
            key = 'value',
            unknown = 'unknown',
          })
          assert.are.same(unknown, { unknown = 'unknown' })
        end)

        it('should be an non-empty table if all keys are defined', function()
          local result, unknown = apply_definitions({
            key1 = { sub_keys = { 'known1' } },
            key2 = { sub_keys = { 'known2' } },
          }, nil, {
            key1 = { known1 = 1, unknown1 = 1 },
            key2 = { known2 = 1, unknown2 = 1, unknown3 = 1 },
            unknown = 'unknown',
          })
          assert.are.same(unknown, {
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
        local result, unknown = define_parse({ 'key' }, kv_string)
        assert.are.same(result, { key = 'value' })
        assert.are.same(unknown, { unknown = 'unknown' })
      end)

      it('can be specified as keys in a Lua table.', function()
        local result, unknown = define_parse({ key = {} }, kv_string)
        assert.are.same(result, { key = 'value' })
        assert.are.same(unknown, { unknown = 'unknown' })
      end)

      it('can be specified by the “name” option.', function()
        local result, unknown = define_parse({ { name = 'key' } }, kv_string)
        assert.are.same(result, { key = 'value' })
        assert.are.same(unknown, { unknown = 'unknown' })
      end)

      it('can be specified in a nested example.', function()
        local result, unknown = define_parse({
          level1 = { sub_keys = { level2 = { sub_keys = { key = {} } } } },
        }, 'level1={level2={key=value,unknown=unknown}}')
        assert.are.same(result, { level1 = { level2 = { key = 'value' } } })
        assert.are.same(unknown,
          { level1 = { level2 = { unknown = 'unknown' } } })
      end)
    end)

    it('Return values: result and unknown', function()
      local parse = define({ { name = 'key1' } })
      local result, unknown = parse('key1=value1')
      assert.are.same(result, { key1 = 'value1' })
      assert.are.same(unknown, {})
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
