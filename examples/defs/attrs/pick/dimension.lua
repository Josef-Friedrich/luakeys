require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({ font_size = { pick = 'dimension' } })
local result = parse('12pt,13pt', { no_error = true })
luakeys.debug(result) -- { font_size = '12pt' }

it('result', function()
  assert.is.same({ font_size = '12pt' }, result)
end)
