require('busted.runner')()

local luakeys = require('luakeys')()
local parse = luakeys.define({ key = { required = true } })

it('Default error', function()
  assert.has_error(function()
    parse('unknown')
  end, 'luakeys error [E012]: Missing required key “key”!')
end)

it('Custom error', function()
  luakeys.error_messages.E012 = 'The key @key is missing!'
  assert.has_error(function()
    parse('unknown')
  end, 'luakeys error [E012]: The key “key” is missing!')
end)
