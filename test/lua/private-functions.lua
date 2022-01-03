require 'busted.runner'()

local luakeys

describe("Test private functions", function()
  setup(function()
    _G._TEST = true
    luakeys = require('luakeys')
  end)

  teardown(function()
    _G._TEST = nil
  end)

  describe('Function “luafy_key()”', function()
    local luafy = luakeys.luafy_key
    it('Whitespaces', function()
      assert.is.equal(luafy('key   one'), 'key_one')
    end)

    it('special characters', function()
      assert.is.equal(luafy('öäü'), '_')
    end)

    it('Numbers', function()
      assert.is.equal(luafy('1 2 3'), '1_2_3')
    end)
  end)

  describe('Function “luafy_options()”', function()
    it('Key containing white spaces', function()
      assert.are.same(luakeys.luafy_options({
        ['key 1'] = 'one',
        ['key 2'] = 'two'
      }), {key_1 = 'one', key_2 = 'two'})
    end)

    it('Empty table', function()
      assert.are.same(luakeys.luafy_options({}), {})
    end)

    it('nil', function()
      assert.are.same(luakeys.luafy_options(), {})
    end)
  end)

  describe('Function “normalize_parse_options()”', function()
    it('No options', function ()
      assert.is.same(luakeys.normalize_parse_options(), {
        convert_dimensions = true,
        unpack_single_array_values = true
      })
    end)

    it('One option', function ()
      assert.is.same(luakeys.normalize_parse_options({
        convert_dimensions = false,
      }), {
        convert_dimensions = false,
        unpack_single_array_values = true
      })
    end)

    it('White spaces', function ()
      assert.is.same(luakeys.normalize_parse_options({
        ['convert dimensions'] = false,
      }), {
        convert_dimensions = false,
        unpack_single_array_values = true
      })
    end)
  end)

  describe('Function “unpack_single_valued_array_table()”', function()
    local unpack = luakeys.unpack_single_valued_array_table

    it('unpacked: single string', function()
      assert.is.equal(unpack({'one'}), 'one')
    end)

    it('Not unpacked: two values', function()
      assert.is.same(unpack({'one', 'two'}), {'one', 'two'})
    end)

    it('Not unpacked: nested table', function()
      assert.is.same(unpack({{'one'}}), {{'one'}})
    end)
  end)
end)
