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

describe('Function “parse()”', function()
  describe('Options', function()
    it('Change default options', function()
      local defaults = luakeys.opts
      local old = defaults.convert_dimensions
      defaults.convert_dimensions = true
      assert.are.same({ 1234567 },
        luakeys.parse('1cm', { naked_as_value = true }))
      defaults.convert_dimensions = false
      assert.are
        .same({ '1cm' }, luakeys.parse('1cm', { naked_as_value = true }))
      -- Restore
      defaults.convert_dimensions = old
    end)

    it('Unknown options should trigger an error message.', function()
      assert.has_error(function()
        luakeys.parse('key', { xxx = true })
      end, 'Unknown parse option: xxx')
    end)

    it('with underscores', function()
      assert.are.same({ '1cm' }, luakeys.parse('1cm', {
        convert_dimensions = false,
        naked_as_value = true,
      }))
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
