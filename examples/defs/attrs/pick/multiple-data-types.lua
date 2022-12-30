require('busted.runner')()
local luakeys = require('luakeys')()

local parse = luakeys.define({
  key = { pick = { 'number', 'dimension' } },
})
local result = parse('string,12pt,42', { no_error = true })
luakeys.debug(result) -- { key = 42 }
local result2 = parse('string,12pt', { no_error = true })
luakeys.debug(result2) -- { key = '12pt' }

it('result', function()
  assert.is.same({ key = 42 }, result)
end)

it('result2', function()
  assert.is.same({ key = '12pt' }, result2)
end)
