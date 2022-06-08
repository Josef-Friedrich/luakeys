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

  describe('Function “visit_tree()”', function()
    local visit = luakeys.visit_tree

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
      end), {})
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
