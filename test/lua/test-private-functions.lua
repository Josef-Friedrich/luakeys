require('busted.runner')()

local luakeys

describe('Test private functions', function()
  setup(function()
    _G._TEST = true
    luakeys = require('luakeys')
  end)

  teardown(function()
    _G._TEST = nil
  end)

  local get_options = function(options)
    return luakeys.normalize_parse_options(options)
  end

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
        ['key 2'] = 'two',
      }), { key_1 = 'one', key_2 = 'two' })
    end)

    it('Empty table', function()
      assert.are.same(luakeys.luafy_options({}), {})
    end)

    it('nil', function()
      assert.are.same(luakeys.luafy_options(), {})
    end)
  end)

  describe('Function “normalize()”', function()
    local normalize = luakeys.normalize

    it('Unchanged', function()
      assert.are.same(normalize({ one = ' one ' }, get_options()),
        { one = ' one ' })
    end)

    describe('Option naked_as_value', function()
      it('true', function()
        assert.are.same(normalize({ 'standalone' },
          get_options({ naked_as_value = false })), { standalone = true })
      end)

      it('true recursive', function()
        assert.are.same(normalize({ level_1 = { level_2 = { 'standalone' } } },
          get_options({ naked_as_value = false, unpack_single_array_values = false })), {
          level_1 = {
            level_2 = { standalone = true },
          },
        })
      end)

      it('false', function()
        assert.are.same(normalize({ 'standalone' },
          get_options({ naked_as_value = true })), { 'standalone' })
      end)
    end)

  end)

  describe('Function “visit_parse_tree()”', function()
    local visit = luakeys.visit_parse_tree

    it('Change the value', function()
      local function callback_func(key, value)
        if type(value) == 'number' then
          return key, value + 1
        end
        return key, value
      end
      assert.is.same(visit({ 1, 2, 3 }, callback_func), { 2, 3, 4 })
      assert.is.same(visit({ l1 = { l2 = 1 } }, callback_func),
        { l1 = { l2 = 2 } })
      assert.has_error(function()
        visit(nil, callback_func)
      end)
    end)

    it('Return nothing', function()
      assert.is.same(visit({ l1 = { l2 = 1 } }, function(key, value)
      end), nil)
    end)

    it('Return key and value unchanged', function()
      assert.is.same(visit({ l1 = { l2 = 1 } }, function(key, value)
        return key, value
      end), { l1 = { l2 = 1 } })
    end)

    it('change keys', function()
      assert.is.same(visit({ l1 = { l2 = 1 } }, function(key, value)
        return 'prefix_' .. key, value
      end), { prefix_l1 = { prefix_l2 = 1 } })
    end)

    it('depth', function()
      local function set_depth(key, value, depth)
        if (value == '%') then
          return key, depth
        end
        return key, value
      end
      local input = { '%', d1 = { '%', d2 = { '%', d3 = { '%' } } } }
      local result = visit(input, set_depth)
      assert.is.same(result, { 1, d1 = { 2, d2 = { 3, d3 = { 4 } } } })
    end)

  end)
end)
