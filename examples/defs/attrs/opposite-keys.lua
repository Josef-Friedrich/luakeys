require('busted.runner')()
local luakeys = require('luakeys')()

local parse = luakeys.define({
  visibility = { opposite_keys = { [true] = 'show', [false] = 'hide' } },
})
local result = parse('show') -- { visibility = true }

it('result', function()
  assert.is.same({ visibility = true }, result)
end)

local result = parse('hide') -- { visibility = false }

it('result', function()
  assert.is.same({ visibility = false }, result)
end)

local parse = luakeys.define({
  visibility = { opposite_keys = { 'show', 'hide' } },
})
local result = parse('show') -- { visibility = true }

it('result', function()
  assert.is.same({ visibility = true }, result)
end)
