require('busted.runner')()
local luakeys = require('luakeys')

local parse =
  luakeys.define({ birthday = { match = '^%d%d%d%d%-%d%d%-%d%d$' } })
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

local parse2 = luakeys.define({ year = { match = '%d%d%d%d' } })
local result2 = parse2('year=1978') -- { year = '1978' }

it('result2', function()
  assert.are.same(result2, { year = '1978' })
end)

local result3 = parse2('year=waste 1978 rubbisch') -- { year = '1978' }
it('result3', function()
  assert.are.same(result3, { year = '1978' })
end)

it('string.match with integer', function()
  assert.are.equal(string.match(2000, '%d%d%d%d'), '2000')
end)
