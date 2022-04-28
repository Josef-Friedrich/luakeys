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

        describe(
          'Name of the keys', function()
            it(
              'can be given as stand-alone values.', function()
                local output = {}
                apply_defintions({ 'key1', 'key2', 'key3' }, { 'key1' }, output)
                assert.are.same(output, { key1 = true })
              end
            )

            it(
              'can be specified as keys in a Lua table.', function()
                local defs = { key1 = { alias = 'k1' }, key2 = { alias = 'k2' } }
                local output = {}
                apply_defintions(defs, { key1 = 'value1' }, output)
                assert.are.same(output, { key1 = 'value1' })
              end
            )

            it(
              'can be specified by the “name” option.', function()
                local output = {}
                apply_defintions(
                  { { name = 'key1' } }, { key1 = 'value1' }, output
                )
                assert.are.same(output, { key1 = 'value1' })
              end
            )
          end
        )

        describe(
          'Options', function()
            it(
              'Option “sub_keys”', function()
                local defs = {
                  { name = 'level1', sub_keys = { { name = 'level2' } } },
                }
                local input = { level1 = { level2 = 'value' } }
                local output = {}
                apply_defintions(defs, input, output)
                assert.are.same(output, { level1 = { level2 = 'value' } })
              end
            )

            describe(
              'Option “alias”', function()
                local defs = {
                  key1 = { alias = 'k1' },
                  key2 = { alias = { 'k2', 'my_key2' } },
                }

                it(
                  'should find a value if the “alias” option is specified as a string and store it under the original key name.',
                  function()
                    local output = {}
                    apply_defintions(defs, { k1 = 42 }, output)
                    assert.are.same(output, { key1 = 42 })
                  end
                )

                it(
                  'should find a value if the “alias” option is specified as an array of string and store it under the original key name.',
                  function()
                    local output = {}
                    apply_defintions(defs, { my_key2 = 42 }, output)
                    assert.are.same(output, { key2 = 42 })
                  end
                )
              end
            )

            describe(
              'Option “opposite_values”', function()
                local defs = {
                  visibility = {
                    opposite_values = { [true] = 'show', [false] = 'hide' },
                  },
                }

                it(
                  'should return true if a truthy string value is given.',
                  function()
                    local output = {}
                    apply_defintions(defs, { 'show' }, output)
                    assert.are.same(output, { visibility = true })
                  end
                )

                it(
                  'should return false if a falsy string is given.', function()
                    local output = {}
                    apply_defintions(defs, { 'hide' }, output)
                    assert.are.same(output, { visibility = false })
                  end
                )

                it(
                  'should return an empty table if a unknown string value is given.',
                  function()
                    local output = {}
                    apply_defintions(defs, { 'unknown' }, output)
                    assert.are.same(output, {})
                  end
                )
              end
            )
          end
        )
      end
    )

    describe(
      'Function “define()”', function()
        local define = luakeys.define

        it(
          'Return values: result and leftover', function()
            local parse = define({ { name = 'key1' } })

            local result, leftover = parse('key1=value1')
            assert.are.same(result, { key1 = 'value1' })
            assert.are.same(leftover, {})
          end
        )
      end
    )

  end
)
