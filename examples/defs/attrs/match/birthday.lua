require('busted.runner')()
local luakeys = require('luakeys')()

local parse = luakeys.define({
  birthday = { match = '^%d%d%d%d%-%d%d%-%d%d$' },
})
local result = parse('birthday=1978-12-03') -- { birthday = '1978-12-03' }

it('result', function()
  assert.are.same(result, { birthday = '1978-12-03' })
end)

it('should throw an error', function()
  assert.has_error(function()
    parse('birthday=1978-12-XX')
    -- throws error message:
    -- 'The value “1978-12-XX” of the key “birthday”
    --  does not match “^%d%d%d%d%-%d%d%-%d%d$”!'
  end,
    'The value “1978-12-XX” of the key “birthday” does not match “^%d%d%d%d%-%d%d%-%d%d$”!')
end)
