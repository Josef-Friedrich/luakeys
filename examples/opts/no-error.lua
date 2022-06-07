require('busted.runner')()
local luakeys = require('luakeys')

assert.has_error(function()
  luakeys.parse('unknown', { defs = { 'key' } })
  -- Error message: Unknown keys: unknown,
end)

luakeys.parse('unknown', { defs = { 'key' }, no_error = true })
-- No error message
