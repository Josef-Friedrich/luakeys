require('busted.runner')()

local luakeys = require('luakeys')

describe('Function “stringify()”', function()
  local function assert_equals(input, expected)
    assert.are.equal(expected, luakeys.stringify(input))
  end

  it('integer indexes', function()
    assert_equals({ 'one' }, '{\n  [1] = \'one\',\n}')
  end)

  it('string indexes', function()
    assert_equals({ ['one'] = 1 }, '{\n  [\'one\'] = 1,\n}')
  end)

  it('nested', function()
    assert_equals({ { 1 } }, '{\n  [1] = {\n    [1] = 1,\n  },\n}')
  end)

  it('option for_tex = true', function()
    assert.are.equal('$\\{$\\par\\ \\ [1] = \'one\',\\par$\\}$',
      luakeys.stringify({ 'one' }, true))
  end)
end)

describe('Function “render()”', function()
  local function assert_render(input, expected)
    assert.are.equal(expected, luakeys.render(
      luakeys.parse(input, { naked_as_value = true })))
  end

  it('standalone value as a string', function()
    assert_render('key', 'key,')
  end)

  it('standalone value as a number', function()
    assert_render('1', '1,')
  end)

  it('standalone value as a dimension', function()
    assert_render('1cm', '1cm,')
  end)

  it('standalone value as a boolean', function()
    assert_render('TRUE', 'true,')
  end)

  it('A list of standalone values', function()
    assert_render('one,two,three', 'one,two,three,')
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
      local parse = luakeys.define({ 'key' },
        { default = 'value' })
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
