require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({ key = { default = 1 } })
local result = parse('') -- { }

it('result', function()
  assert.is.same({}, result)
end)

local parse = luakeys.define({ key = { default = 1, always_present = true } })
local result = parse('') -- { key =  1 }

it('result', function()
  assert.is.same({ key = 1 }, result)
end)
