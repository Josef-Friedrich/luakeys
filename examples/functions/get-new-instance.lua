require('busted.runner')()

local my_luakeys = require('luakeys').get_new_instance()
local result = my_luakeys.parse('key=value')

it('result', function()
  assert.is.same(result, { key = 'value' })
end)

it('version', function()
  assert.is.equal(type(my_luakeys.version), 'table')
end)

local l1 = require('luakeys') -- table: 0x564ea6ca4160
local l2 = require('luakeys') -- table: 0x564ea6ca4160
local l3 = require('luakeys').get_new_instance() -- table: 0x563574d51470
local l4 = require('luakeys').get_new_instance() -- table: 0x563574d86ac0

it('compare the global instance', function()
  assert.is.equal(l1, l2)
end)

it('compare the private instances', function()
  assert.is.not_equal(l1, l3)
  assert.is.not_equal(l2, l3)
  assert.is.not_equal(l3, l4)
end)
