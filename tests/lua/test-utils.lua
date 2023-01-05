require('busted.runner')()

local utils = require('luakeys')().utils

describe('utils', function()
  local color = utils.ansi_color

  describe('ansi_color', function()
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

end)
