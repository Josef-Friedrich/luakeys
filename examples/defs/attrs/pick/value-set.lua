require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({ font_size = { pick = 'dimension' } })
local result, unknown =
  parse('font_size=11pt,12pt', { no_error = true })
luakeys.debug(result) -- { font_size = '11pt' }
luakeys.debug(unknown) -- { '12pt' }

it('result', function()
  assert.is.same({ font_size = '11pt' }, result)
end)

it('unknown', function()
  assert.is.same({ '12pt' }, unknown)
end)
