local luaunit = require('luaunit')
local luakeys = require('luakeys')

local assertEquals = luaunit.assertEquals

local parser = luakeys.build_parser()

local function parse(input)
  return parser:match(input)
end

function test_datatype_integer()
  assertEquals(parse('key=1'), { key = 1 })
end

function test_datatype_boolean()
  local function assert_true(true_string)
    assertEquals(parse('key=' .. true_string), { key = true })
  end
  assert_true('true')
  assert_true('TRUE')
  assert_true('yes')
  assert_true('YES')
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
