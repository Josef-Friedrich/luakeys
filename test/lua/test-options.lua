require('busted.runner')()
local luakeys = require('luakeys')

describe('Options', function()
  describe('Option “defaults”', function()
    local function assert_defaults(kv_string, defaults, expected)
      assert.are.same(luakeys.parse(kv_string, {
        defaults = defaults,
        naked_as_value = true,
      }), expected)
    end

    it('Should add a default key.', function()
      assert_defaults('key1=new', { key1 = 'default', key2 = 'default' },
        { key1 = 'new', key2 = 'default' })
    end)

    it('Should not overwrite an existing value', function()
      assert_defaults('key=new', { key = 'old' }, { key = 'new' })
    end)

    it('Should work in a nested table', function()
      assert_defaults('level1={level2={key1=new}}', {
        level1 = { level2 = { key1 = 'default', key2 = 'default' } },
      }, { level1 = { level2 = { key1 = 'new', key2 = 'default' } } })
    end)

    it('Should not merge arrays, integer indexed values.', function()
      assert_defaults('a,b', { 'c', 'd' }, { 'a', 'b' })
    end)

    it('Should be able to merge empty defaults.', function()
      assert_defaults('a,b', {}, { 'a', 'b' })
    end)

    it('Should be able to merge empty targets.', function()
      assert_defaults('', { 'c', 'd' }, { 'c', 'd' })
    end)

    it('Should join the keys.', function()
      assert_defaults('a=A', { b = 'B' }, { a = 'A', b = 'B' })
    end)

    it('Should join the keys of nested tables.', function()
      assert_defaults('a=A,b={c=C}', { b = { d = 'D' } },
        { a = 'A', b = { c = 'C', d = 'D' } })
    end)
  end)
end)
