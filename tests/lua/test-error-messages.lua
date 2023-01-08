require('busted.runner')()

local luakeys = require('luakeys')()

describe('error_messages', function()
  it('Set a custom error message.', function()
    luakeys.error_messages.E019 = 'custom'

    assert.has_error(function()
      luakeys.parse('unknown = unknown',
        { defs = { key = { data_type = 'string' } } })
    end, 'luakeys error [E019]: custom')
  end)
end)
