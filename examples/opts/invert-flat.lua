require('busted.runner')()
local luakeys = require('luakeys')()

local result = luakeys.parse('naked1,!naked2')
luakeys.debug(result) -- { naked1 = true, naked2 = false }

it('result', function()
  assert.is.same({ naked1 = true, naked2 = false }, result)
end)

local result2 = luakeys.parse('naked1,~naked2', { invert_flag = '~' })
luakeys.debug(result2) -- { naked1 = true, naked2 = false }

it('result3', function()
  assert.is.same({ naked1 = true, naked2 = false }, result2)
end)

local result3 = luakeys.parse('naked1,!naked2', { default = false })
luakeys.debug(result3) -- { naked1 = false, naked2 = true }

it('result3', function()
  assert.is.same({ naked1 = false, naked2 = true }, result3)
end)

local result4 = luakeys.parse('naked1,!naked2', { invert_flag = false })
luakeys.debug(result4) -- { naked1 = true, ['!naked2'] = true }

it('result4', function()
  assert.is.same({ naked1 = true, ['!naked2'] = true }, result4)
end)
