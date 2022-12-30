require('busted.runner')()
local luakeys = require('luakeys')

local result = luakeys.utils.merge_tables({ key = 'target' }, {
  key = 'source',
  key2 = 'new',
}, true)
luakeys.debug(result) -- { key = 'source', key2 = 'new' }

it('result', function()
  assert.are.same({ key = 'source', key2 = 'new' }, result)
end)

local result2 = luakeys.utils.merge_tables({ key = 'target' }, {
  key = 'source',
  key2 = 'new',
}, false)
luakeys.debug(result2) -- { key = 'target', key2 = 'new' }

it('result2', function()
  assert.are.same({ key = 'target', key2 = 'new' }, result2)
end)
