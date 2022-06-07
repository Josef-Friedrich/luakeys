require('busted.runner')()
local luakeys = require('luakeys')

-- a single alias
local parse = luakeys.define({ key = { alias = 'k' } })
local result = parse('k=value')
luakeys.debug(result) -- { key = 'value' }

it('result', function ()
  assert.is.same({ key = 'value' }, result)
end)

-- multiple aliases
local parse = luakeys.define({ key = { alias = { 'k', 'ke' } } })
local result = parse('ke=value')
luakeys.debug(result) -- { key = 'value' }

it('result', function ()
  assert.is.same({ key = 'value' }, result)
end)
