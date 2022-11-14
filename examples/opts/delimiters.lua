require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse(
  'level1: ( key1: value1; key2: “A string;” )', {
    assignment_operator = ':',
    group_begin = '(',
    group_end = ')',
    list_separator = ';',
    quotation_begin = '“',
    quotation_end = '”',
  })
luakeys.debug(result) -- { level1 = { key1 = 'value1', key2 = 'A string;' } }

it('result', function()
  assert.are.same({ level1 = { key1 = 'value1', key2 = 'A string;' } },
    result)
end)
