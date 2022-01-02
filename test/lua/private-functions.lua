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

  it('Function “normalize_parse_options()”', function()
    assert.is.same(luakeys.normalize_parse_options(), {
      convert_dimensions = true,
      unpack_single_array_values = true
    })
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
