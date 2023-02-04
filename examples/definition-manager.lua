require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
  key1 = { default = 1 },
  key2 = { default = 2 },
  key3 = { default = 3 },
})

local def = manager:get('key1')
luakeys.debug(def) -- { default = 1 }

local defs1 = manager:include({ 'key2' })
luakeys.debug(defs1) -- { key2 = { default = 2 } }

local defs2 = manager:exclude({ 'key2' })
luakeys.debug(defs2) -- { key1 = { default = 1 }, key3 = { default = 3 } }

manager:parse('key3', { 'key3' }) -- { key3 = 3 }
manager:parse('new3', { key3 = 'new3' }) -- { new3 = 3 }
--manager:parse('key1', { 'key3' }) -- 'Unknown keys: “key1,”'
