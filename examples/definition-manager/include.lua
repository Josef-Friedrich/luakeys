require('busted.runner')()
local luakeys = require('luakeys')()

local DefinitionManager = luakeys.DefinitionManager

local manager = DefinitionManager({
    key1 = { default = 1 },
    key2 = { default = 2 },
    key3 = { default = 3 },
})

it('clone = false', function()
    local defs = manager:include({ 'key3' })
    assert.is.equal(defs.key3.default, 3)
    ---@diagnostic disable-next-line: undefined-field
    assert.is.equal(defs.key3, manager.defs.key3)
end)

it('clone = true', function()
    local defs = manager:include({ 'key3' }, true)
    ---@diagnostic disable-next-line: undefined-field
    assert.is_not.equal(defs.key3, manager.defs.key3)
end)

it('key_spec = nil -> all definitions are returned', function()
    local defs = manager:include()
    assert.are.same(defs, {
        key1 = { default = 1 },
        key2 = { default = 2 },
        key3 = { default = 3 },
    })
end)
