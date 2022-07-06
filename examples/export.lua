require('busted.runner')()

local luakeys = require('luakeys')
local version = luakeys.version
local opts = luakeys.opts
local stringify = luakeys.stringify
local define = luakeys.define
local parse = luakeys.parse
local render = luakeys.render
local debug = luakeys.debug
local save = luakeys.save
local get = luakeys.get
local is = luakeys.is

it('Exported', function()
  assert.is.equal(type(version), 'table')
  assert.is.equal(type(opts), 'table')
  assert.is.equal(type(stringify), 'function')
  assert.is.equal(type(define), 'function')
  assert.is.equal(type(parse), 'function')
  assert.is.equal(type(render), 'function')
  assert.is.equal(type(debug), 'function')
  assert.is.equal(type(save), 'function')
  assert.is.equal(type(get), 'function')
  assert.is.equal(type(is), 'table')
end)
