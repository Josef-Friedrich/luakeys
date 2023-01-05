require('busted.runner')()

local utils = require('luakeys')().utils

describe('utils', function()
  local color = utils.ansi_color

  it('Function “merge_tables”', function()
    local result = utils.merge_tables({ target = 'target' }, { source = 'source' })
    assert.are.same(result, { target = 'target', source = 'source' })
  end)

  it('Function “clone_table”', function()
    local result =
      utils.clone_table({ l1 = { l2 = { l3 = 'level3' } } })
    assert.are.same(result, { l1 = { l2 = { l3 = 'level3' } } })
  end)

  it('Function “throw_error_message”', function()
    assert.has_error(function()
      utils.throw_error_message('My error message')
    end, 'My error message')
  end)

  it('Function “throw_error_code”', function()
    assert.has_error(function()
      utils.throw_error_code({ E13 = 'Black @friday' }, 'E13',
        { friday = 'FRIDAY' })
    end, 'luakeys error [E13]: Black “FRIDAY”')
  end)

  describe('Table “ansi_color”', function()
    it('colorize', function()
      assert.are.equal(color.colorize('green', 'green', 'bright', true),
        '\27[1m\27[42mgreen\27[0m')
    end)

    it('red', function()
      assert.are.equal(color.red('red'), '\27[31mred\27[0m')
    end)

    it('green', function()
      assert.are.equal(color.green('green'), '\27[32mgreen\27[0m')
    end)

    it('yellow', function()
      assert.are.equal(color.yellow('yellow'), '\27[33myellow\27[0m')
    end)

    it('blue', function()
      assert.are.equal(color.blue('blue'), '\27[34mblue\27[0m')
    end)

    it('magenta', function()
      assert.are.equal(color.magenta('magenta'), '\27[35mmagenta\27[0m')
    end)

    it('cyan', function()
      assert.are.equal(color.cyan('cyan'), '\27[36mcyan\27[0m')
    end)
  end)

  describe('Table “log”', function ()
    local log = utils.log
    it('Error', function ()
      assert.has_error(function ()
        log.set_log_level('xxx')
      end, 'Unknown log level: xxx')
    end)

    it('Error', function ()
      assert.has_error(function ()
        log.set_log_level(6)
      end, 'Log level out of range 0-5: 6')
    end)
  end)
end)
