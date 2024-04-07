require('busted.runner')()

local luakeys = require('luakeys')()

local parse = luakeys.parse

local function assert_deep_equals(actual, expected, opts)
  assert.are.same(expected, parse(actual, opts))
end

describe('Real world examples', function()
  describe('gitinfo-lua', function()
    it('Manual page ?: 0.0.1,flags={no-merges}', function()
        local parse_commit_opts = luakeys.define({
            rev_spec = { data_type = 'string', pick = 'string' },
            files = { data_type = 'list' },
            cwd = { data_type = 'string' },
            flags = {
                sub_keys = {
                    merges = { data_type='boolean', exclusive_group='merges' },
                    ['no-merges'] = { data_type='boolean', exclusive_group='merges' }
                }
            }
        })
        local actual = '0.0.1,flags={no-merges}'
        local expected = {flags = {['no-merges'] = true}, rev_spec = '0.0.1'}
        assert.are.same(expected, parse_commit_opts(actual))
      end)
    end)
  describe('hyperref', function()
    it('Manual page 6: pdfborder={0 0 0}', function()
      assert_deep_equals('pdfborder={0 0 0}', { pdfborder = '0 0 0' })
    end)

    it('Manual page 6: backref...', function()
      assert_deep_equals('backref,\npdfpagemode=FullScreen,\ncolorlinks=true', {
        backref = true,
        colorlinks = true,
        pdfpagemode = 'FullScreen',
      })
    end)

    it('Manual page 15: pdfinfo...', function()
      assert_deep_equals(
        'pdfinfo={\nTitle={My Title},\nSubject={My Subject},\nNewKey={Foobar},\n}',
        {
          pdfinfo = {
            NewKey = 'Foobar',
            Subject = 'My Subject',
            Title = 'My Title',
          },
        }, { naked_as_value = true })
    end)
  end)

  describe('tikz', function()
    it('Manual page 330', function()
      assert_deep_equals('matrix of math nodes,\n' ..
                           'column sep={2cm,between origins},\n' ..
                           'row sep={3cm,between origins},\n' ..
                           'nodes={circle, draw, minimum size=7.5mm}', {
        'matrix of math nodes',
        ['column sep'] = { '2cm', 'between origins' },
        nodes = { 'circle', 'draw', ['minimum size'] = '7.5mm' },
        ['row sep'] = { '3cm', 'between origins' },
      }, { naked_as_value = true })
    end)

    it('Manual page 241', function()
      assert_deep_equals('every node/.style=draw',
        { ['every node/.style'] = 'draw' })
    end)

    it('Manual page 237', function()
      assert_deep_equals(
        'fill=yellow!80!black,text width=3cm,align=flush center', {
          align = 'flush center',
          fill = 'yellow!80!black',
          ['text width'] = '3cm',
        })
    end)

  end)

  describe('fontspec', function()
    it('Manual page 11', function()
      assert_deep_equals(
        'Extension = .ttf ,\n' .. 'UprightFont = CharisSILR,\n' ..
          'BoldFont = CharisSILB,\n' .. 'ItalicFont = CharisSILI,\n' ..
          'BoldItalicFont = CharisSILBI,\n', {
          BoldFont = 'CharisSILB',
          BoldItalicFont = 'CharisSILBI',
          Extension = '.ttf',
          ItalicFont = 'CharisSILI',
          UprightFont = 'CharisSILR',
        })
    end)

    it('Manual page 17 #skip', function()
      assert_deep_equals(
        'Extension = .otf ,\n' .. 'UprightFont = *-Light ,\n' ..
          'BoldFont = *-Regular ,\n' .. 'FontFace = {k}{n}{*-Black} ,', {
          Extension = '.otf',
          UprightFont = '*-Light',
          BoldFont = '*-Regular',
          FontFace = '{k}{n}{*-Black}', -- < !
        })
    end)

    it('Manual page 18', function()
      assert_deep_equals('lots and lots ,\n' .. 'and more and more ,\n' ..
                           'an excessive number really ,\n' ..
                           'of font features could go here\n', {
        'lots and lots',
        'and more and more',
        'an excessive number really',
        'of font features could go here',
      }, { naked_as_value = true })
    end)

  end)

  describe('geometry', function()
    it('Manual page 16', function()
      assert_deep_equals(
        'hdivide={*,0.9\\paperwidth,*}, vdivide={*,0.9\\paperheight,*}', {
          hdivide = { '*', '0.9\\paperwidth', '*' }, -- < ?
          vdivide = { '*', '0.9\\paperheight', '*' }, -- < ?
        }, { naked_as_value = true })
    end)

    it('Manual page 17', function()
      assert_deep_equals('a5paper, landscape, twocolumn, twoside,\n' ..
                           'left=2cm, hmarginratio=2:1, includemp, marginparwidth=43pt,\n' ..
                           'bottom=1cm, foot=.7cm, includefoot, textheight=11cm, heightrounded,\n' ..
                           'columnsep=1cm, dvips, verbose', {
        a5paper = true,
        landscape = true,
        twocolumn = true,
        twoside = true,
        left = '2cm',
        hmarginratio = '2:1', -- < ?
        includemp = true,
        marginparwidth = '43pt',
        bottom = '1cm',
        foot = '.7cm',
        includefoot = true,
        textheight = '11cm',
        heightrounded = true,
        columnsep = '1cm',
        dvips = true,
        verbose = true,
      })
    end)
  end)
end)
