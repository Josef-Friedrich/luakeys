require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({ year = { match = '%d%d%d%d' } })
local result = parse('year=1978') -- { year = '1978' }

it('result', function()
  assert.are.same(result, { year = '1978' })
end)

local result2 = parse('year=waste 1978 rubbisch') -- { year = '1978' }
it('result', function()
  assert.are.same(result2, { year = '1978' })
end)

it('string.match with integer', function()
  assert.are.equal(string.match(2000, '%d%d%d%d'), '2000')
end)
