require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({
  level1 = {
    sub_keys = { level2 = { default = 2 }, key = { pick = 'boolean' } },
  },
}, { no_error = true })
local result, unknown = parse('true,level1={level2,true}')
luakeys.debug(result) -- { level1 = { key = true, level2 = 2 } }
luakeys.debug(unknown) -- { true }

it('result', function()
  assert.is.same({ level1 = { key = true, level2 = 2 } }, result)
end)

it('unknown', function()
  assert.is.same({ true }, unknown)
end)
