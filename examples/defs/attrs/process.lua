require('busted.runner')()
local luakeys = require('luakeys')

local parse = luakeys.define({
  key = {
    process = function(value, input, result, unknown)
      if type(value) == 'number' then
        return value + 1
      end
      return value
    end,
  },
})
local result = parse('key=1') -- { key = 2 }

it('result', function()
  assert.is.same({ key = 2 }, result)
end)

------------------------------------------------------------------------

local parse2 = luakeys.define({
  'one',
  'two',
  key = {
    process = function(value, input, result, unknown)
      value = input.one + input.two
      result.one = nil
      result.two = nil
      return value
    end,
  },
})
local result2 = parse2('key,one=1,two=2') -- { key = 3 }

it('result', function()
  assert.is.same({ key = 3 }, result2)
end)

------------------------------------------------------------------------

local parse3 = luakeys.define({
  key = {
    process = function(value, input, result, unknown)
      result.additional_key = true
      return value
    end,
  },
})
local result3 = parse3('key=1') -- { key = 1, additional_key = true }

it('result', function()
  assert.is.same({ key = 1, additional_key = true }, result3)
end)

------------------------------------------------------------------------

local parse4 = luakeys.define({
  key = {
    process = function(value, input, result, unknown)
      unknown.unknown_key = true
      return value
    end,
  },
})

it('Error message', function()
  assert.has_error(function()
    parse4('key=1') -- throws error message: 'Unknown keys: unknown_key=true,'
  end, 'Unknown keys: unknown_key=true,')
end)
