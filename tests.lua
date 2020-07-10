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

function test_datatype_integer()
  assertEquals(parse('integer=1'), { integer = 1 })
end

function test_datatype_boolean()
  local function assert_boolean(boolean_string, value)
    local boolean_parser = luakeys.build_parser({
      key = {
        type = 'boolean'
      }
    })
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


os.exit( luaunit.LuaUnit.run() )


-- test('dimension', 'margin=2pt')

-- test('', 'hide,margin=2pt,textcolor =red,linecolor=green, show,')
-- test('', 'one=true,two=TRUE,three = false, four=FALSE,five')
-- test('', 'one=no,two=NO,three = yes, four=YES,five')
-- test('Multiline', [[
--   hide,
--   margin=2pt,
--   textcolor =red
-- ]])


-- test('minlines -> minimum lines', 'minlines=3')
