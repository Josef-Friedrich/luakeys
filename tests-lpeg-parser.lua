local luaunit = require('luaunit')
local generate_parser = require('luakeys-lpeg-parser')

local parser = generate_parser()

local function parse(input)
  return parser:match(input)
end

local assertEquals = luaunit.assertEquals

function test_empty_string()
  assertEquals(true, true)
end

function test_datatype_number()
  local assert_equals = function(input, output)
    assertEquals(parse('key=' .. input), { key = output })
  end

  assert_equals('1.1', 1.1)
  assert_equals('+1.1', 1.1)
  assert_equals('-1.1', -1.1)
  assert_equals('11e-02', 0.11)
  assert_equals('11e-02', 11e-02)
  assert_equals('-11e-02', -0.11)
  assert_equals('+11e-02', 0.11)
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
