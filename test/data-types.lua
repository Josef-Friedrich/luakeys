local luaunit = require('luaunit')
local luakeys = require('luakeys')
-- luarocks install inspect
-- local inspect = require('inspect')

local parse = luakeys.parse

local assertEquals = luaunit.assertEquals

function test_empty_string()
  assertEquals(true, true)
end

function test_datatypes()
  local function assert_type(value, expected_type)
    local result = luakeys.parse('key=' .. value)
    luaunit.assert_equals(type(result.key), expected_type)
  end

  assert_type('1', 'number')
  assert_type(' 1 ', 'number')
  -- assert_type('1 lol', 'string')
  -- assert_type(' 1 lol ', 'string')
  assert_type('1.1', 'number')
  assert_type('1cm', 'number')
  assert_type('-1.4cm', 'number')
  assert_type('-0.4pt', 'number')
  assert_type('true', 'boolean')
  assert_type('false', 'boolean')
  assert_type('FALSE', 'boolean')
  assert_type('"lol"', 'string')
end

function test_datatype_string()
  local function assert_string(input, value)
    assertEquals(parse('string=' .. input), {string = value})
  end
  assert_string('"1"', '1')
  assert_string('"1\\\"test\\\"2"', '1\\\"test\\\"2')
  assert_string('"1,2"', '1,2')
end

function test_datatype_dimension()
  local function assert_dimension(value)
    local result = luakeys.parse('key=' .. value)
    luaunit.assert_equals(result.key, 1234567)
  end

  assert_dimension('1cm')
  assert_dimension('-1cm')
  assert_dimension('+1cm')
  assert_dimension('1 cm')
  assert_dimension('- 1 cm')
  assert_dimension('+ 1 cm')
  assert_dimension('1CM')
end

os.exit(luaunit.LuaUnit.run())
