local luaunit = require('luaunit')
local luakeys = require('luakeys')

local assertEquals = luaunit.assertEquals

local parser = luakeys.build_parser({
  integer = {
    type = 'integer',
    alias = 'int'
  },
  boolean = {
    type = 'boolean',
    alias = { 'bool', 'b'} -- long alias first
  },
  keyonly = {
    type = 'keyonly'
  }
})

parser:match('integer=1')

local function parse(input)
  return parser:match(input)
end

function test_empty_string()
  assertEquals(parse(''), {})
end

function test_alias()
  assertEquals(parse('int=1'), { integer = 1 })
  assertEquals(parse('b=yes'), { boolean = true })
  assertEquals(parse('bool=true'), { boolean = true })
end

function test_keyonly()
  assertEquals(parse('keyonly'), { keyonly = true })
end

function test_datatype_integer()
  assertEquals(parse('integer=1'), { integer = 1 })
end

function test_datatype_boolean()
  local boolean_parser = luakeys.build_parser({
    key = {
      type = 'boolean'
    }
  })
  local function assert_boolean(boolean_string, value)
    assertEquals(boolean_parser:match('key=' .. boolean_string), { key = value })
  end
  assert_boolean('true', true)
  assert_boolean('TRUE', true)
  assert_boolean('yes', true)
  assert_boolean('YES', true)

  assert_boolean('false', false)
  assert_boolean('FALSE', false)
  assert_boolean('no', false)
  assert_boolean('NO', false)
end

function test_datatype_dimension()
  local dim_parser = luakeys.build_parser({
    dim = {
      type = 'dimension'
    }
  })

  local function assert_dim(dim_string)
    assertEquals(dim_parser:match('dim=' .. dim_string), { dim = 123 })
  end
  assert_dim('1.1cm')
  assert_dim('1,1cm')
  assert_dim('-1.1cm')
  assert_dim('- 1.1cm')
  assert_dim('+1.1cm')
  assert_dim('+ 1.1cm')
  assert_dim('1 cm')
  assert_dim('1,1 cm')

  assert_dim('1bp')
  assert_dim('1cc')
  assert_dim('1cm')
  assert_dim('1dd')
  assert_dim('1em')
  assert_dim('1ex')
  assert_dim('1in')
  assert_dim('1mm')
  assert_dim('1nc')
  assert_dim('1nd')
  assert_dim('1pc')
  assert_dim('1pt')
  assert_dim('1sp')
end

os.exit( luaunit.LuaUnit.run() )
