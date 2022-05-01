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
                assert.are.same(
                  apply_defintions({ 'key1', 'key2', 'key3' }, { 'key1' }),
                  { key1 = true }
                )
              end
            )

            it(
              'can be specified as keys in a Lua table.', function()
                local defs = { key1 = { alias = 'k1' }, key2 = { alias = 'k2' } }
                assert.are.same(
                  apply_defintions(defs, { key1 = 'value1' }),
                  { key1 = 'value1' }
                )
              end
            )

            it(
              'can be specified by the “name” option.', function()
                assert.are.same(
                  apply_defintions(
                    { { name = 'key1' } }, { key1 = 'value1' }
                  ), { key1 = 'value1' }
                )
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
                assert.are.same(
                  apply_defintions(defs, input),
                  { level1 = { level2 = 'value' } }
                )
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
                    assert.are
                      .same(apply_defintions(defs, { k1 = 42 }), { key1 = 42 })
                  end
                )

                it(
                  'should find a value if the “alias” option is specified as an array of string and store it under the original key name.',
                  function()
                    assert.are.same(
                      apply_defintions(defs, { ['my_key2'] = 42 }),
                      { key2 = 42 }
                    )
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
                    assert.are.same(
                      apply_defintions(defs, { 'show' }), { visibility = true }
                    )
                  end
                )

                it(
                  'should return false if a falsy string is given.', function()
                    assert.are.same(
                      apply_defintions(defs, { 'hide' }), { visibility = false }
                    )
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

            describe(
              'Option “exclusive_group”', function()
                local defs = {
                  k1 = { exclusive_group = 'group1' },
                  k2 = { exclusive_group = 'group1' },
                  k3 = { exclusive_group = 'group3' },
                  k4 = { default = 'value' },
                }

                it(
                  'should pass if only one key of the mutually exclusive group is present.',
                  function()
                    assert.are.same(
                      apply_defintions(defs, { k1 = 'value' }), { k1 = 'value' }
                    )
                  end
                )

                it(
                  'should throw an error if only two keys of the mutually exclusive group are present.',
                  function()
                    assert.has_error(
                      function()
                        apply_defintions(
                          defs, { k1 = 'value', k2 = 'value' }, {}
                        )
                      end
                    )
                  end
                )

                it(
                  'should let other keys untouched.', function()
                    assert.are
                      .same(apply_defintions(defs, { 'k4' }), { k4 = 'value' })
                  end
                )

                it(
                  'two keys of two different exclusive groups should pass.',
                  function()
                    assert.are.same(
                      apply_defintions(defs, { k1 = 'value', k3 = 'value' }),
                      { k1 = 'value', k3 = 'value' }
                    )
                  end
                )
              end
            )

            it(
              'Option “process”', function()
                assert.are.same(
                  apply_defintions(
                    {
                      width = {
                        process = function(value)
                          if type(value) == 'number' and value >= 0 and value <=
                            1 then
                            return tostring(value) .. '\\linewidth'
                          end
                          return value
                        end,
                      },
                    }, { width = 0.5 }
                  ), { width = '0.5\\linewidth' }
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

        it(
          'should merge inner default options', function()
            local parse = define({ 'key1', 'key2' })
            local result = parse('key1=value1', {}, { key2 = 'value2' })
            assert.are.same(result, { key1 = 'value1', key2 = 'value2' })
          end
        )

        it(
          'should merge outer default options', function()
            local parse = define({ 'key1', 'key2' }, nil, { key2 = 'value2' })
            local result = parse('key1=value1')
            assert.are.same(result, { key1 = 'value1', key2 = 'value2' })
          end
        )
      end
    )

  end
)
