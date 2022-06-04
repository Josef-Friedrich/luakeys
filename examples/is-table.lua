require('busted.runner')()
local luakeys = require('luakeys')

local equal = assert.is.equal

it('Function “boolean()”', function()
  -- true
  equal(luakeys.is.boolean('true'), true)
  equal(luakeys.is.boolean('True'), true)
  equal(luakeys.is.boolean('TRUE'), true)
  equal(luakeys.is.boolean('false'), true)
  equal(luakeys.is.boolean('False'), true)
  equal(luakeys.is.boolean('FALSE'), true)
  equal(luakeys.is.boolean(true), true)
  equal(luakeys.is.boolean(false), true)
  -- false
  equal(luakeys.is.boolean('xxx'), false)
  equal(luakeys.is.boolean('trueX'), false)
  equal(luakeys.is.boolean('1'), false)
  equal(luakeys.is.boolean('0'), false)
  equal(luakeys.is.boolean(1), false)
  equal(luakeys.is.boolean(0), false)
  equal(luakeys.is.boolean(nil), false)
end)

describe('Function “dimension()”', function()
  -- true
  equal(luakeys.is.dimension('1 cm'), true)
  equal(luakeys.is.dimension('- 1 mm'), true)
  equal(luakeys.is.dimension('-1.1pt'), true)
  -- false
  equal(luakeys.is.dimension('1cmX'), false)
  equal(luakeys.is.dimension('X1cm'), false)
  equal(luakeys.is.dimension(1), false)
  equal(luakeys.is.dimension('1'), false)
  equal(luakeys.is.dimension('xxx'), false)
  equal(luakeys.is.dimension(nil), false)
end)

it('Function “integer()”', function()
  -- true
  equal(luakeys.is.integer('42'), true)
  equal(luakeys.is.integer(1), true)
  -- false
  equal(luakeys.is.integer('1.1'), false)
  equal(luakeys.is.integer('xxx'), false)
end)

it('Function “number()”', function()
  -- true
  equal(luakeys.is.number(1), true)
  equal(luakeys.is.number(1.1), true)
  equal(luakeys.is.number('1'), true)
  equal(luakeys.is.number('1.1'), true)
  -- false
  equal(luakeys.is.number('xxx'), false)
  equal(luakeys.is.number('1cm'), false)
end)

it('Function “string()”', function()
  -- true
  equal(luakeys.is.string('string'), true)
  equal(luakeys.is.string(''), true)
  -- false
  equal(luakeys.is.string(true), false)
  equal(luakeys.is.string(1), false)
  equal(luakeys.is.string(nil), false)
end)
