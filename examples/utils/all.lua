require('busted.runner')()

local utils = require('luakeys')().utils

---table
local merge_tables = utils.merge_tables
local clone_table = utils.clone_table
local remove_from_table = utils.remove_from_table
local get_table_keys = utils.get_table_keys
local get_table_size = utils.get_table_size
local get_array_size = utils.get_array_size

---error
local throw_error_message = utils.throw_error_message
local throw_error_code = utils.throw_error_code

local scan_oarg = utils.scan_oarg

---ansi_color
local colorize = utils.ansi_color.colorize
local red = utils.ansi_color.red
local green = utils.ansi_color.green
local yellow = utils.ansi_color.yellow
local blue = utils.ansi_color.blue
local magenta = utils.ansi_color.magenta
local cyan = utils.ansi_color.cyan

---log
local set_log_level = utils.log.set_log_level
local err = utils.log.error
local warn = utils.log.warn
local info = utils.log.info
local verbose = utils.log.verbose
local debug = utils.log.debug

it('Exported', function()
  local function assert_function(f)
    assert.is.equal(type(f), 'function')
  end
  assert_function(merge_tables)
  assert_function(clone_table)
  assert_function(remove_from_table)
  assert_function(get_table_keys)
  assert_function(get_table_size)
  assert_function(get_array_size)

  assert_function(throw_error_message)
  assert_function(throw_error_code)

  assert_function(scan_oarg)

  assert_function(colorize)
  assert_function(red)
  assert_function(green)
  assert_function(yellow)
  assert_function(blue)
  assert_function(magenta)
  assert_function(cyan)

  assert_function(set_log_level)
  assert_function(err)
  assert_function(warn)
  assert_function(info)
  assert_function(verbose)
  assert_function(debug)
end)
