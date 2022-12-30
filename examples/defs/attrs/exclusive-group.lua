require('busted.runner')()
local luakeys = require('luakeys')()

local parse = luakeys.define({
  key1 = { exclusive_group = 'group' },
  key2 = { exclusive_group = 'group' },
})
local result1 = parse('key1') -- { key1 = true }
local result2 = parse('key2') -- { key2 = true }

it('result1', function()
  assert.are.same(result1, { key1 = true })
end)

it('result2', function()
  assert.are.same(result2, { key2 = true })
end)

it('error message', function()
  assert.has_error(function()
    parse('key1,key2') -- throws error message:
    -- 'The key “key2” belongs to a mutually exclusive group “group”
    -- and the key “key1” is already present!'
  end) -- Test flaps

  -- Test flaps between

  -- 'The key “key1” belongs to a mutually exclusive group “group” and
  -- the key “key2” is already present!'

  -- 'The key “key2” belongs to a mutually exclusive group “group” and
  -- the key “key1” is already present!'
end)
