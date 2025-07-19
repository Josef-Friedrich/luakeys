require('busted.runner')()

local luakeys = require('luakeys')()

describe('Function “render()”', function()
  local big_input = {
    ['level 1'] = {
      level_2 = {
        nil_value = nil,
        string_value = 'string',
        number_value = 1.23,
        boolean_value = true,
      },
    },
    'Array element 1',
    'Array element 2',
    ['Key with a , (comma)'] = 'Value with a , (comma)',
  }

  ---
  ---@param input unknown
  ---@param expected string
  ---@param opts? RenderConfiguration
  local function assert_render(input, expected, opts)
    assert.are.equal(expected, luakeys.render(input, opts))
  end

  describe('key=value', function()
    it('style=tex', function()
      assert_render({ key = 'value' }, 'key=value')
    end)

    describe('style=lua', function()
      it('identifier', function()
        assert_render({ key = 'value' }, '{key=\'value\'}',
          { style = 'lua' })
      end)

      it('no identifier as key', function()
        assert_render({ ['key 1'] = 'value' },
          '{[\'key 1\']=\'value\'}', { style = 'lua' })
      end)
    end)
  end)

  describe('Nesting', function()
    local input = { level1 = { level2 = { level3 = 'value' } } }

    it('inline=true', function()
      assert_render(input, 'level1={level2={level3=value}}')
    end)

    it('style=lua', function()
      assert_render(input, '{level1={level2={level3=\'value\'}}}',
        { style = 'lua' })
    end)

    it('inline=false', function()
      assert_render(input,
        '\n' .. '  level1 = {\n' .. '    level2 = {\n' ..
          '      level3 = value\n' .. '    }\n' .. '  }\n',
        { inline = false })
    end)
  end)

  it('Empty table', function()
    assert_render({ {}, {}, {} }, '{},{},{}')
  end)

  it('standalone value as a string', function()
    assert_render({ 'key' }, 'key')
  end)

  describe('standalone value as a number', function()
    it('style=tex', function()
      assert_render({ 1 }, '1')
    end)

    it('style=lua', function()
      assert_render({ 1 }, '{1}', { style = 'lua' })
    end)
  end)

  it('standalone value as a dimension', function()
    assert_render({ '1cm' }, '1cm')
  end)

  it('standalone value as a boolean', function()
    assert_render({ true }, 'true')
  end)

  describe('A list of standalone values', function()
    it('style=tex', function()
      assert_render({ 'one', 'two', 'three' }, 'one,two,three')
    end)

    it('inline=false', function()
      assert_render({ 'one', 'two', 'three' },
        '\n' .. '  one,\n' .. '  two,\n' .. '  three\n',
        { inline = false })
    end)

    it('style=lua', function()
      assert_render({ 'one', 'two', 'three' },
        '{\'one\',\'two\',\'three\'}', { style = 'lua' })
    end)
  end)

  describe('Big input table', function()
    it('tex', function()
      assert_render(big_input, [[

  Array element 1,
  Array element 2,
  "Key with a , (comma)" = "Value with a , (comma)",
  level 1 = {
    level_2 = {
      boolean_value = true,
      number_value = 1.23,
      string_value = string
    }
  }
]], { inline = false })
    end)

    it('lua', function()
      assert_render(big_input, [[
{
  'Array element 1',
  'Array element 2',
  ['Key with a , (comma)'] = 'Value with a , (comma)',
  ['level 1'] = {
    level_2 = {
      boolean_value = true,
      number_value = 1.23,
      string_value = 'string'
    }
  }
}]], { inline = false, style = 'lua' })
    end)
  end)

  describe('Options', function()
    it('line_break', function()
      assert_render({ 'one', 'two' }, '+one,+two+', { line_break = '+' })
    end)

    it('begin_table', function()
      assert_render({ key = { 'value' } }, 'key=(value}',
        { begin_table = '(' })
    end)

    it('end_table', function()
      assert_render({ key = { 'value' } }, 'key={value)',
        { end_table = ')' })
    end)

    it('table_delimiters_first_depth', function()
      assert_render({ key = { 'value' } }, '{key={value}}',
        { table_delimiters_first_depth = true })
    end)

    it('indent', function()
      assert_render({ key = { 'value' } }, '++key={++++value++}',
        { indent = '++' })
    end)

    it('begin_key', function()
      assert_render({ ['key 1'] = { 'value' } },
        '{#\'key 1\']={\'value\'}}', { begin_key = '#', style = 'lua' })
    end)

    it('end_key', function()
      assert_render({ ['key 1'] = { 'value' } },
        '{[\'key 1\'#={\'value\'}}', { end_key = '#', style = 'lua' })
    end)

    it('assignment', function()
      assert_render({ key = 'value' }, 'key::value',
        { assignment = '::' })
    end)

    it('separator', function()
      assert_render({ 'one', 'two' }, 'one;two', { separator = ';' })
    end)

    it('separator_last', function()
      assert_render({ 'one', 'two' }, 'one,two,',
        { separator_last = true })
    end)

    it('quotation', function()
      assert_render({ 'one 1' }, '{"one 1"}',
        { quotation = '"', style = 'lua' })
    end)

    it('format_key', function()
      assert_render({ key = 'value' }, 'xxx=value', {
        format_key = function(key)
          return 'xxx'
        end,
      })
    end)

    it('format_value', function()
      assert_render({ key = 'value' }, 'key=xxx', {
        format_value = function(key)
          return 'xxx'
        end,
      })
    end)
  end)

  describe('Different input data types', function()
    it('boolean', function()
      assert_render(true, 'true')
    end)

    it('number', function()
      assert_render(1.23, '1.23')
    end)

    it('nil', function()
      assert_render(nil, 'nil')
    end)

    it('string', function()
      assert_render('string', 'string')
    end)
  end)
end)

describe('Function “define()”', function()
  it('returns a parse function', function()
    local parse = luakeys.define({ { name = 'key1' } })
    local result, unknown = parse('key1=value1')
    assert.are.same(result, { key1 = 'value1' })
    assert.are.same(unknown, {})
  end)

  it('specify “opts” on the “parse” function', function()
    local parse = luakeys.define({ 'key1', 'key2' })
    local result = parse('key1=value1',
      { defaults = { key2 = 'value2' } })
    assert.are.same(result, { key1 = 'value1', key2 = 'value2' })
  end)

  it('specify “opts” on the “define” function', function()
    local parse = luakeys.define({ 'key1', 'key2' },
      { defaults = { key2 = 'value2' } })
    local result = parse('key1=value1')
    assert.are.same(result, { key1 = 'value1', key2 = 'value2' })
  end)

  it(
    'specify “opts” in both the “define” and the “parse” function',
    function()
      local parse = luakeys.define({ 'key' }, { default = 'value' })
      local result, unknown = parse('key,unknown', { no_error = true })
      assert.are.same(result, { key = 'value' })
      assert.are.same(unknown, { [2] = 'unknown' })
    end)
end)

describe('Function “parse()”', function()
  describe('Return values', function()
    describe('Second return value: “unknown”', function()
      it('should be an empty table if all keys are defined', function()
        local _, unknown = luakeys.parse('key=value',
          { defs = { 'key' } })
        assert.are.same(unknown, {})
      end)

      it('should be a non-empty table if some keys are not defined',
        function()
          local _, unknown =
            luakeys.parse('key=value,unknown=unknown',
              { defs = { 'key' }, no_error = true })
          assert.are.same(unknown, { unknown = 'unknown' })
        end)

      it('Should be a non-empty table in a recursive example',
        function()
          local _, unknown = luakeys.parse(
            'key1={known1=1,unknown1=1},key2={known2=1,unknown2=1,unknown3=1},unknown=unknown',
            {
              no_error = true,
              defs = {
                key1 = { sub_keys = { 'known1' } },
                key2 = { sub_keys = { 'known2' } },
              },
            })
          assert.are.same(unknown, {
            key1 = { unknown1 = 1 },
            key2 = { unknown2 = 1, unknown3 = 1 },
            unknown = 'unknown',
          })
        end)
    end)
  end)
end)

it('Function “debug()”', function()
  luakeys.debug({ key = 'value' })
end)

describe('Functions “save()” and “get()”', function()
  it('Save and get with an existent identifier', function()
    luakeys.save('test123', 'Some value')
    assert.is.equal(luakeys.get('test123'), 'Some value')
  end)

  it('Throws error #skip', function()
    assert.has_error(function()
      luakeys.get('xxx')
    end, 'No stored result was found for the identifier \'xxx\'')
  end)
end)

describe('Table “is”', function()
  describe('Function “boolean()”', function()
    it('should return false', function()
      assert.is.equal(luakeys.is.boolean('xxx'), false)
      assert.is.equal(luakeys.is.boolean('1'), false)
      assert.is.equal(luakeys.is.boolean('0'), false)
      assert.is.equal(luakeys.is.boolean(1), false)
      assert.is.equal(luakeys.is.boolean(0), false)
      assert.is.equal(luakeys.is.boolean(), false)
    end)

    it('should return true', function()
      assert.is.equal(luakeys.is.boolean(true), true)
      assert.is.equal(luakeys.is.boolean(false), true)
      assert.is.equal(luakeys.is.boolean('true'), true)
      assert.is.equal(luakeys.is.boolean('True'), true)
      assert.is.equal(luakeys.is.boolean('TRUE'), true)
      assert.is.equal(luakeys.is.boolean('false'), true)
      assert.is.equal(luakeys.is.boolean('False'), true)
      assert.is.equal(luakeys.is.boolean('FALSE'), true)
    end)
  end)

  describe('Function “dimension()”', function()
    it('should return false', function()
      assert.is.equal(luakeys.is.dimension('xxx'), false)
    end)

    it('should return false if the input is nil', function()
      assert.is.equal(luakeys.is.dimension(), false)
    end)

    it('should return true', function()
      assert.is.equal(luakeys.is.dimension('1 cm'), true)
    end)
  end)

  describe('Function “integer()”', function()
    it('should return false', function()
      assert.is.equal(luakeys.is.integer('1.1'), false)
    end)

    it('should return false if input is a string', function()
      assert.is.equal(luakeys.is.integer('xxx'), false)
    end)

    it('should return false if input is a integer', function()
      assert.is.equal(luakeys.is.integer(1), true)
    end)

    it('should return true', function()
      assert.is.equal(luakeys.is.integer('134'), true)
    end)
  end)

  it('Function “number()”', function()
    assert.is.equal(luakeys.is.number(1), true)
    assert.is.equal(luakeys.is.number(1.1), true)
    assert.is.equal(luakeys.is.number('1'), true)
    assert.is.equal(luakeys.is.number('1.1'), true)
  end)

  it('Function “string()”', function()
    assert.is.equal(luakeys.is.string(''), true)
    assert.is.equal(luakeys.is.string('string'), true)
    assert.is.equal(luakeys.is.string(true), false)
    assert.is.equal(luakeys.is.string(1), false)
    assert.is.equal(luakeys.is.string(), false)
  end)
end)
