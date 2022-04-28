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
              'can be given als stand-alone values.', function()
                local output = {}
                apply_defintions({ 'key1', 'key2', 'key3' }, { 'key1' }, output)
                assert.are.same(output, { key1 = true })
              end
            )

            it(
              'should be specified by the “name” option.', function()
                local output = {}
                apply_defintions(
                  { { name = 'key1' } }, { key1 = 'value1' }, output
                )
                assert.are.same(output, { key1 = 'value1' })
              end
            )

            it(
              'should be specified as table keys', function()
                local defs = { key1 = { alias = 'k1' }, key2 = { alias = 'k2' } }
                local output = {}
                apply_defintions(
                  defs, { key1 = 'value1', key2 = 'value2' }, output
                )
                assert.are.same(output, { key1 = 'value1', key2 = 'value2' })
              end
            )
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

        describe(
          'Option “opposite_values”', function()
            local defs = {
              visibility = {
                opposite_values = { [true] = 'show', [false] = 'hide' },
              },
            }

            it(
              'should return true', function()
                local output = {}
                apply_defintions(defs, { 'show' }, output)
                assert.are.same(output, { visibility = true })
              end
            )

            it(
              'should return false', function()
                local output = {}
                apply_defintions(defs, { 'hide' }, output)
                assert.are.same(output, { visibility = false })
              end
            )

            it(
              'unknown value', function()
                local output = {}
                apply_defintions(defs, { 'unknown' }, output)
                assert.are.same(output, {})
              end
            )
          end
        )

        describe(
          'Option “default”', function()
            local defs = { key = { default = 42, always_present = true } }

            it(
              'should be used if the key is not present.', function()
                local output = {}
                apply_defintions(defs, { 'unkown' }, output)
                assert.are.same(output, { key = 42 })
              end
            )

            it(
              'should not be used if the key with its associated value is present.',
              function()
                local output = {}
                apply_defintions(defs, { key = 23 }, output)
                assert.are.same(output, { key = 23 })
              end
            )

            describe(
              'nested (recursive) definition', function()
                local mested_defs = {
                  level1 = {
                    sub_keys = {
                      level2 = { default = 42, always_present = true },
                    },
                  },
                }

                it(
                  'should be used if the key is not present.', function()
                    local output = {}
                    apply_defintions(
                      mested_defs, { level1 = { 'unknown' } }, output
                    )
                    assert.are.same(output, { level1 = { level2 = 42 } })
                  end
                )

                it(
                  'should not be used if the key with its associated value is present.',
                  function()
                    local output = {}
                    apply_defintions(
                      mested_defs, { level1 = { level2 = 23 } }, output
                    )
                    assert.are.same(output, { level1 = { level2 = 23 } })
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
