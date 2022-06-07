require('busted.runner')()
local luakeys = require('luakeys')

local result, unknown = luakeys.parse('level1={level2,unknown}', {
  no_error = true,
  defs = {
    level1 = {
      sub_keys = {
        level2 = { default = 42 }
      }
    }
  },
})
luakeys.debug(result) -- { level1 = { level2 = 42 } }
luakeys.debug(unknown) -- { level1 = { 'unknown' } }

it('result', function ()
  assert.is.same(result, { level1 = { level2 = 42 } })
end)

it('unknown', function ()
  assert.is.same(unknown, { level1 = { [2] = 'unknown' } })
end)
