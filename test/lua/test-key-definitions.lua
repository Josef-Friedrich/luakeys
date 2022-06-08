require('busted.runner')()

local luakeys

describe('Key definitions', function()
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
        local defs = { key = {} }
        assert.are.same(apply_definitions(defs, nil, get_input()),
          { key = 'value' })
      end)

      it('can be specified by the “name” option.', function()
        assert.are.same(
          apply_definitions({ { name = 'key' } }, nil, get_input()),
          { key = 'value' })
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

    local function define_parse(defs, kv_string)
      local parse = define(defs)
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
