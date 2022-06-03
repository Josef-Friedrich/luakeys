require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.parse('level1={level2={key=value}}')
luakeys.debug(result)
