require('busted.runner')()

local utils = require('luakeys').utils

local merge_tables = utils.merge_tables
local clone_table = utils.clone_table
local remove_from_table = utils.remove_from_table
local get_table_size = utils.get_table_size
local get_array_size = utils.get_array_size
local scan_oarg = utils.scan_oarg

it('Exported', function()
  assert.is.equal(type(merge_tables), 'function')
  assert.is.equal(type(clone_table), 'function')
  assert.is.equal(type(remove_from_table), 'function')
  assert.is.equal(type(get_table_size), 'function')
  assert.is.equal(type(get_array_size), 'function')
  assert.is.equal(type(scan_oarg), 'function')
end)
