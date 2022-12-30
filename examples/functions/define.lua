require('busted.runner')()
local luakeys = require('luakeys')()

-- standalone string values
local defs = { 'key' }

-- keys in a Lua table
local defs = { key = {} }

-- by the “name” attribute
local defs = { { name = 'key' } }

local parse = luakeys.define(defs)
local result, unknown = parse('key=value,unknown=unknown', { no_error = true })
luakeys.debug(result) -- { key = 'value' }
luakeys.debug(unknown) -- { unknown = 'unknown' }

it('result', function()
  assert.is.same(result, { key = 'value' })
end)

it('unknown', function()
  assert.is.same(unknown, { unknown = 'unknown' })
end)

local parse2 = luakeys.define({
  level1 = {
    sub_keys = { level2 = { sub_keys = { key = { } } } },
  },
}, { no_error = true })
local result2, unknown2 = parse2('level1={level2={key=value,unknown=unknown}}')
luakeys.debug(result2) -- { level1 = { level2 = { key = 'value' } } }
luakeys.debug(unknown2) -- { level1 = { level2 = { unknown = 'unknown' } } }

it('result2', function()
  assert.is.same(result2, { level1 = { level2 = { key = 'value' } } })
end)

it('unknown2', function()
  assert.is.same(unknown2, { level1 = { level2 = { unknown = 'unknown' } } })
end)
