local luaunit = require('luaunit')
local luakeys = require('luakeys')

local parse = luakeys.parse

local assertEquals = luaunit.assertEquals

function test_empty_string()
  assertEquals(true, true)
end

function test_datatype_number()
  local assert_number = function(input, output)
    assertEquals(parse('key=' .. input), { key = output })
  end
  assert_number('1', 1)
  assert_number('1.1', 1.1)
  assert_number('+1.1', 1.1)
  assert_number('-1.1', -1.1)
  assert_number('11e-02', 0.11)
  assert_number('11e-02', 11e-02)
  assert_number('-11e-02', -0.11)
  assert_number('+11e-02', 0.11)
end

--- @todo remove
function test_datatype_boolean_ng()
  local function assert_boolean(boolean_string, value)
    assertEquals(parse('key=' .. boolean_string), { key = value })
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

function test_datatype_string()
  local function assert_string(input, value)
    assertEquals(parse('string=' .. input), { string = value })
  end
  assert_string('"1"', '1')
  assert_string('"1\\\"test\\\"2"', '1\\\"test\\\"2')
  assert_string('"1,2"', '1,2')
end

function test_white_spaces()
  assertEquals(parse('integer=1'), { integer = 1 })
  assertEquals(parse('integer = 2'), { integer = 2 })
  assertEquals(parse('integer\t=\t3'), { integer = 3 })
  assertEquals(parse('integer\n=\n4'), { integer = 4 })
  assertEquals(parse('integer \t\n= \t\n5 , boolean=no'), { integer = 5, boolean = false })
  assertEquals(parse('integer=1 , boolean=no'), { integer = 1, boolean = false })
  assertEquals(parse('integer \t\n= \t\n1 \t\n, \t\nboolean \t\n= \t\nno'), { integer = 1, boolean = false })
end

function test_multiple_keys()
  assertEquals(parse('integer=1,boolean=no'), { integer = 1, boolean = false })
  assertEquals(parse('integer=1 , boolean=no'), { integer = 1, boolean = false })
end

function test_edge_cases()
  assertEquals(parse(''), {})
  assertEquals(parse(',,'), {})
  assertEquals(parse(',,,'), {})
  assertEquals(parse(', , ,'), {})
  assertEquals(parse(' ,'), {})
  assertEquals(parse(', '), {})
end

function test_duplicate_keys()
  assertEquals(parse('integer=1,integer=2'), { integer = 2})
  assertEquals(parse('integer=1 , integer=2'), { integer = 2})
end

function test_all()
  assertEquals(parse('one,two,three'), {'one', 'two', 'three'})
  assertEquals(parse('1,2,3'), {1, 2, 3})
  assertEquals(parse('level1={level2={level3=level3}}'), {level1={level2={level3="level3"}}})
  assertEquals(parse('string = without quotes'), {string="without quotes"})
  assertEquals(parse('string = "with quotes: ,={}"'), {string="with quotes: ,={}"})
  assertEquals(parse('number = -0.123'), {number=-0.123})
end

os.exit( luaunit.LuaUnit.run() )
