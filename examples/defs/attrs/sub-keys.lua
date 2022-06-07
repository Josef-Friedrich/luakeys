require('busted.runner')()
local luakeys = require('luakeys')

local result, leftover = luakeys.parse('level1={level2,unknown}', {
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
luakeys.debug(leftover) -- { level1 = { 'unknown' } }

it('result', function ()
  assert.is.same(result, { level1 = { level2 = 42 } })
end)

it('leftover', function ()
  assert.is.same(leftover, { level1 = { [2] = 'unknown' } })
end)
