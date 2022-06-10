require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({ font_size = { pick = 'dimension' } })
local result = parse('12pt') -- { font_size = '12pt' }

it('result', function()
  assert.is.same({ font_size = '12pt' }, result)
end)

------------------------------------------------------------------------

local parse2 = luakeys.define({
  level1 = {
    sub_keys = { level2 = { default = 2 }, key = { pick = 'boolean' } },
  },
}, { no_error = true })
local result2, unknown2 = parse2('true,level1={level2,true}')
luakeys.debug(result2) -- { level1 = { key = true, level2 = 2 } }
luakeys.debug(unknown2) -- { true }

it('result2', function()
  assert.is.same({ level1 = { key = true, level2 = 2 } }, result2)
end)

it('unknown2', function()
  assert.is.same({ true }, unknown2)
end)

------------------------------------------------------------------------

local parse3 = luakeys.define({ font_size = { pick = 'dimension' } })
local result3, unknown3 = parse('font_size=11pt,12pt',
  { no_error = true })
luakeys.debug(result3) -- { font_size = '11pt' }
luakeys.debug(unknown3) -- { true }

it('result3', function()
  assert.is.same({ font_size = '11pt' }, result3)
end)

it('unknown3', function()
  assert.is.same({ '12pt' }, unknown3)
end)
