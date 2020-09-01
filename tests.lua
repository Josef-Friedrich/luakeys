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

--- @todo remove
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

  assert_boolean('false', false)
  assert_boolean('FALSE', false)
  assert_boolean('no', false)
  assert_boolean('NO', false)
end

--- @todo remove
function test_datatype_boolean_ng()
  local local_parser = luakeys.generate_parser()
  local function assert_boolean(boolean_string, value)
    assertEquals(local_parser:match('key=' .. boolean_string), { key = value })
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
      data_type = 'dimension'
    }
  })

  local function assert_dim(dim_string)
    assertEquals(dim_parser:match('dim=' .. dim_string), { dim = 123 })
  end
  assert_dim('1.1cm')
  assert_dim('-1.1cm')
  assert_dim('+1.1cm')
  assert_dim('1cm')

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

-- @todo: remove
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

function test_datatype_number()
  local local_parser = luakeys.generate_parser()

  local assert_equals = function(input, output)
    luaunit.assert_equals(local_parser:match('key=' .. input), { key = output })
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
  local local_parser = luakeys.build_parser({ string = { data_type = 'string' } })

  local function assert_string(input, value)
    assertEquals(local_parser:match('string=' .. input), { string = value })
  end
  assert_string('"1"', '1')
  assert_string('"1\\\"test\\\"2"', '1\\\"test\\\"2')
  assert_string('"1,2"', '1,2')
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

function test_error_E01_defintion_no_table()
  luaunit.assert_error_msg_contains(
    'luakeys error (E01): The key-value defintions must be a table.',
    function()
      luakeys.check_definitions('string')
    end
  )
end

function test_error_E02_choices_no_table()
  luaunit.assert_error_msg_contains(
    'Key \'key\': choices definition has to be a table.',
    function()
      luakeys.build_parser({
        key = { choices = 'A String' }
      })
    end
  )
end

function test_error_E03_undefined_key()
  luaunit.assert_error_msg_contains(
    'luakeys error (E03): Undefined key \'key2\'.',
    function()
      local parser = luakeys.build_parser({ key1 = { data_type = 'integer' } })
      parser:match('key2=1')
    end
  )
end

function test_error_E04_unsupported_data_type()
  luaunit.assert_error_msg_contains(
    'luakeys error (E04): Unsupported data type \'lol\'.',
    function()
      luakeys.build_parser({ key = { data_type = 'lol' } })
    end
  )
end

function test_error_E05_not_allowed_choice()
  luaunit.assert_error_msg_contains(
    'luakeys error (E05): Not allowed choice \'four\' for key \'key\'.',
    function()
      local choices_parser = luakeys.build_parser({
        key = { choices = {'one', 'two', 'three'} }
      })
      choices_parser:match('key=four')
    end
  )
end

function test_error_E06_wrong_data_type()
  luaunit.assert_error_msg_contains(
    "luakeys error (E06): Wrong data type (key: 'key', value: '5', defined data type: 'boolean', actual data type: 'number')",
    function()
      local local_parser = luakeys.build_parser({
        key = { data_type = 'boolean' }
      })
      local_parser:match('key=5')
    end
  )
end

function test_error_E07_duplicate_complementary_value()
  local normalize = function(raw)
    luakeys.normalize_complementary_values(
      {
        show = {
          complementary = {
            'show', 'hide'
          }
        }
      },
      raw
    )
  end

  luaunit.assert_error_msg_contains(
    "Duplicate usage of the complementary value 'hide' that gets stored under the key 'show'.",
    function() normalize({ 'hide', 'hide' }) end
  )

  luaunit.assert_error_msg_contains(
    "Duplicate usage of the complementary value 'show' that gets stored under the key 'show'.",
    function() normalize({ 'show', 'show' }) end
  )
  luaunit.assert_error_msg_contains(
    "Duplicate usage of the complementary value 'show' that gets stored under the key 'show'.",
    function() normalize({ 'hide', 'show' }) end
  )
  luaunit.assert_error_msg_contains(
    "Duplicate usage of the complementary value 'hide' that gets stored under the key 'show'.",
    function() normalize({ 'show', 'hide' }) end
  )
end

function test_function_get_type()
  luaunit.assert_equals(luakeys.get_type('1'), 'number')
  luaunit.assert_equals(luakeys.get_type(' 1 '), 'number')
  luaunit.assert_equals(luakeys.get_type('1 lol'), 'string')
  luaunit.assert_equals(luakeys.get_type(' 1 lol '), 'string')
  luaunit.assert_equals(luakeys.get_type('1.1'), 'number')
  luaunit.assert_equals(luakeys.get_type('1cm'), 'dimension')
  luaunit.assert_equals(luakeys.get_type('-1.4cm'), 'dimension')
  luaunit.assert_equals(luakeys.get_type('-0.4pt'), 'dimension')
  luaunit.assert_equals(luakeys.get_type('true'), 'boolean')
  luaunit.assert_equals(luakeys.get_type('yes'), 'boolean')
  luaunit.assert_equals(luakeys.get_type('NO'), 'boolean')
  luaunit.assert_equals(luakeys.get_type('"lol"'), 'string')
end

function test_function_generate_parser()
  local local_parser = luakeys.generate_parser()

  local assert_equals = function(input, output)
    luaunit.assert_equals(local_parser:match(input), output)
  end

  assert_equals('one,two,three', {'one', 'two', 'three'})
  assert_equals('1,2,3', {1, 2, 3})
  assert_equals('level1={level2={level3=level3}}', {level1={level2={level3="level3"}}})
  assert_equals('string = without quotes', {string="without quotes"})
  assert_equals('string = "with quotes: ,={}"', {string="with quotes: ,={}"})
  assert_equals('number = -0.123', {number=-0.123})
end

function test_function_normalize_complementary_values()
  local normalize = luakeys.normalize_complementary_values

  local defs = {
    show = {
      complementary = {
        'show', 'hide'
      }
    }
  }

  local assert_equals = function(raw, output)
    luaunit.assert_equals(normalize(defs, raw), output)
  end

  assert_equals({ 'hide' }, { show = false })
  assert_equals({ 'show' }, { show = true })
  assert_equals({ 'show', key = 'value' }, { show = true, key = 'value' })
  assert_equals({ 'show', 'value' }, { show = true, 'value' })
  assert_equals({ 'value' , 'show' }, { 'value', show = true })
end

function test_function_normalize_alias_keys_table()
  local normalize = luakeys.normalize_alias_keys

  local defs = {
    key = {
      alias = {
        'key1', 'key2'
      }
    }
  }

  local assert_equals = function(raw, output)
    luaunit.assert_equals(normalize(defs, raw), output)
  end

  assert_equals({ key1 = true }, { key = true })
  assert_equals({ key2 = true }, { key = true })
  assert_equals({ key = true }, { key = true })
  assert_equals({ some_key = true }, { some_key = true })
end

function test_function_normalize_alias_keys_string()
  local normalize = luakeys.normalize_alias_keys

  local defs = {
    key = {
      alias = 'key1'
    }
  }

  local assert_equals = function(raw, output)
    luaunit.assert_equals(normalize(defs, raw), output)
  end

  assert_equals({ key1 = true }, { key = true })
  assert_equals({ key2 = true }, { key2 = true })
  assert_equals({ key = true }, { key = true })
  assert_equals({ some_key = true }, { some_key = true })
end

os.exit( luaunit.LuaUnit.run() )
