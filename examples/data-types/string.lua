require('busted.runner')()
local luakeys = require('luakeys')()

local kv_string = [[
  without double quotes = no commas and equal signs are allowed,
  with double quotes = ", and = are allowed",
  escape quotes = "a quote \" sign",
  curly braces = "curly { } braces are allowed",
]]
local result = luakeys.parse(kv_string)
luakeys.debug(result)
-- {
--   ['without double quotes'] = 'no commas and equal signs are allowed',
--   ['with double quotes'] = ', and = are allowed',
--   ['escape quotes'] = 'a quote \" sign',
--   ['curly braces'] = 'curly { } braces are allowed',
-- }

it('result', function()
  assert.is.same({
    ['without double quotes'] = 'no commas and equal signs are allowed',
    ['with double quotes'] = ', and = are allowed',
    ['escape quotes'] = 'a quote \\" sign',
    ['curly braces'] = 'curly { } braces are allowed',
  }, result)
end)
