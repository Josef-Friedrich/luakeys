require('busted.runner')()
local luakeys = require('luakeys')()

local parse = luakeys.define({ important = { required = true } })
local result = parse('important') -- { important = true }

it('result', function()
  assert.is.same({ important = true }, result)
end)

it('should throw an error if the key is missing', function()
  assert.has_error(function()
    parse('unimportant')
    -- throws error message: 'Missing required key “important”!'
  end, 'Missing required key “important”!')
end)

local parse2 = luakeys.define({
  important1 = {
    required = true,
    sub_keys = { important2 = { required = true } },
  },
})

it(
  'should throw an error if the key is missing in a recursive example (level 2)',
  function()
    assert.has_error(function()
      parse2('important1={unimportant}')
      -- throws error message: 'Missing required key “important2”!'
    end, 'Missing required key “important2”!')
  end)

it(
  'should throw an error if the key is missing in a recursive example (level 1)',
  function()
    assert.has_error(function()
      parse2('unimportant')
      -- throws error message: 'Missing required key “important1”!'
    end, 'Missing required key “important1”!')
  end)
