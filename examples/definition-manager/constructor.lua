require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

it('Constructor', function()
    local m = DefinitionManager({
        { name = 'named1', default = 1 },
        { name = 'named2', default = 2 },
        unnamed = { default = 0 },
    })
    assert.is.equal(m:get('named1').default, 1)
    assert.is.equal(m:get('named2').default, 2)
    assert.is.equal(m:get('unnamed').default, 0)
end)
