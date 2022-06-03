require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({ key = { choices = { 'one', 'two', 'three' } } })
local result = parse('key=one') -- { key = 'one' }

it('result', function()
  assert.are.same(result, { key = 'one' })
end)

it('error message.', function()
  assert.has_error(function()
    parse('key=unknown')
    -- error message:
    --- 'The value “unknown” does not exist in the choices: one, two, three!'
  end, 'The value “unknown” does not exist in the choices: one, two, three!')
end)
