require('busted.runner')()

local luakeys = require('luakeys')()
local new = luakeys.new
local version = luakeys.version
local parse = luakeys.parse
local define = luakeys.define
local opts = luakeys.opts
local error_messages = luakeys.error_messages
local render = luakeys.render
local stringify = luakeys.stringify
local debug = luakeys.debug
local save = luakeys.save
local get = luakeys.get
local is = luakeys.is
local utils = luakeys.utils

it('Exported', function()
  assert.is.equal(type(new), 'function')
  assert.is.equal(type(version), 'table')
  assert.is.equal(type(parse), 'function')
  assert.is.equal(type(define), 'function')
  assert.is.equal(type(opts), 'table')
  assert.is.equal(type(error_messages), 'table')
  assert.is.equal(type(render), 'function')
  assert.is.equal(type(stringify), 'function')
  assert.is.equal(type(debug), 'function')
  assert.is.equal(type(save), 'function')
  assert.is.equal(type(get), 'function')
  assert.is.equal(type(is), 'table')
  assert.is.equal(type(utils), 'table')
end)
