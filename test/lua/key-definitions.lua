require 'busted.runner'()

local luakeys

describe(
  'Key defintions', function()
    setup(
      function()
        _G._TEST = true
        luakeys = require('luakeys')
      end
    )

    teardown(
      function()
        _G._TEST = nil
      end
    )

    describe(
      'Function “apply_defintions()”', function()
        local apply_defintions = luakeys.apply_definitions

        it(
          'Simple example', function()
            local output = {}
            apply_defintions({ { name = 'key1' } }, { key1 = 'value1' }, output)
            assert.are.same(output, { key1 = 'value1' })
          end
        )

        it(
          'Sub keys', function()
            local defs = {
              { name = 'level1', sub_keys = { { name = 'level2' } } },
            }
            local input = { level1 = { level2 = 'value' } }
            local output = {}
            apply_defintions(defs, input, output)
            assert.are.same(output, { level1 = { level2 = 'value' } })
          end
        )
      end
    )

  end
)
