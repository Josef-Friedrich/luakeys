local luaunit = require('luaunit')
local luakeys = require('luakeys')

local assertEquals = luaunit.assertEquals

local parser, defaults = luakeys.build_parser({
  integer = {
    data_type = 'integer',
    alias = 'int',
    default = 3,
  },
  boolean = {
    data_type = 'boolean',
    alias = { 'bool', 'b'}, -- long alias first
    default = true
  },
  keyonly = {
    data_type = 'keyonly'
  }
})

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
      data_type = 'boolean'
    }
  })
  local function assert_boolean(boolean_string, value)
    assertEquals(boolean_parser:match('key=' .. boolean_string), { key = value })
  end
  assert_boolean('true', true)
  assert_boolean('TRUE', true)
  assert_boolean('yes', true)
  assert_boolean('YES', true)
  assert_boolean('1', true)

  assert_boolean('false', false)
  assert_boolean('FALSE', false)
  assert_boolean('no', false)
  assert_boolean('NO', false)
  assert_boolean('0', false)
end

function test_datatype_dimension()
  local dim_parser = luakeys.build_parser({
    dim = {
      data_type = 'dimension'
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

function test_datatype_float()
  local float_parser = luakeys.build_parser({
    float = {
      data_type = 'float'
    }
  })

  local function assert_float(float_string, value)
    assertEquals(float_parser:match('float=' .. float_string), { float = value })
  end
  assert_float('1.1', 1.1)
  assert_float('+1.1', 1.1)
  assert_float('-1.1', -1.1)
  assert_float('11e-02', 0.11)
  assert_float('11e-02', 11e-02)
  assert_float('-11e-02', -0.11)
  assert_float('+11e-02', 0.11)
end

function test_defaults()
  assertEquals(defaults.integer, 3)
  assertEquals(defaults.boolean, true)
end

function test_rename_key()
  local parser = luakeys.build_parser({
    old_key = {
      data_type = 'integer',
      rename_key = 'new_key'
    }
  })
  assertEquals(parser:match('old_key=1'), { new_key = 1 })
end

function test_overwrite_value()
  local parser = luakeys.build_parser({
    key = {
      data_type = 'integer',
      overwrite_value = 2
    }
  })
  assertEquals(parser:match('key=1'), { key = 2 })
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

function test_choices()
  local choices_parser = luakeys.build_parser({
    key = {
      choices = {'one', 'two', 'three'}
    }
  })

  assertEquals(choices_parser:match('key=one'), { key = 'one'})
end

function test_choices_error()
  luaunit.assert_error_msg_contains(
    'Key \'key\': choices definition has to be a table.',
    function()
      luakeys.build_parser({
        key = { choices = 'A String' }
      })
    end
  )
end

os.exit( luaunit.LuaUnit.run() )
