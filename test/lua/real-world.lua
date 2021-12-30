require 'busted.runner'()

local luakeys = require('luakeys')

local parse = luakeys.parse

local function assert_deep_equals(actual, expected)
  assert.are.same(expected, parse(actual))
end

describe('Real world examples', function()
  describe('hyperref', function()
    it('Manual page 6: pdfborder={0 0 0}', function()
      assert_deep_equals('pdfborder={0 0 0}', {pdfborder = {0, 0, 0}})
    end)

    it('Manual page 6: backref...', function()
      assert_deep_equals('backref,\npdfpagemode=FullScreen,\ncolorlinks=true', {
        'backref',
        colorlinks = true,
        pdfpagemode = 'FullScreen'
      })
    end)

    it('Manual page 15: pdfinfo...', function()
      assert_deep_equals(
        'pdfinfo={\nTitle={My Title},\nSubject={My Subject},\nNewKey={Foobar},\n}',
        {
          pdfinfo = {
            NewKey = 'Foobar',
            Subject = 'My Subject',
            Title = 'My Title'
          }
        })
    end)
  end)

  describe('tikz', function()
    it('Manual page 330', function()
      assert_deep_equals('matrix of math nodes,\n' ..
                           'column sep={2cm,between origins},\n' ..
                           'row sep={3cm,between origins},\n' ..
                           'nodes={circle, draw, minimum size=7.5mm}', {
        'matrix of math nodes',
        ['column sep'] = {1234567, 'between origins'},
        nodes = {'circle', 'draw', ['minimum size'] = 1234567},
        ['row sep'] = {1234567, 'between origins'}
      })
    end)

    it('Manual page 241', function()
      assert_deep_equals('every node/.style=draw',
                         {['every node/.style'] = 'draw'})
    end)

    it('Manual page 237', function()
      assert_deep_equals(
        'fill=yellow!80!black,text width=3cm,align=flush center', {
          align = 'flush center',
          fill = 'yellow!80!black',
          ['text width'] = 1234567
        })
    end)

  end)

  describe('fontspec', function()
    it('Manual page 11', function()
      assert_deep_equals(
        'Extension = .ttf ,\n' .. 'UprightFont = CharisSILR,\n' ..
          'BoldFont = CharisSILB,\n' .. 'ItalicFont = CharisSILI,\n' ..
          'BoldItalicFont = CharisSILBI,\n' .. '% <any other desired options>\n',
        {
          '% <any other desired options>', -- ???
          BoldFont = 'CharisSILB',
          BoldItalicFont = 'CharisSILBI',
          Extension = '.ttf',
          ItalicFont = 'CharisSILI',
          UprightFont = 'CharisSILR'
        })
    end)

    it('Manual page 17 #skip', function()
      assert_deep_equals(
        'Extension = .otf ,\n' .. 'UprightFont = *-Light ,\n' ..
          'BoldFont = *-Regular ,\n' .. 'FontFace = {k}{n}{*-Black} ,', {
          Extension = '.otf',
          UprightFont = '*-Light',
          BoldFont = '*-Regular',
          FontFace = '{k}{n}{*-Black}' -- < !
        })
    end)

    it('Manual page 18', function()
      assert_deep_equals('lots and lots ,\n' .. 'and more and more ,\n' ..
                           'an excessive number really ,\n' ..
                           'of font features could go here\n', {
        'lots and lots', 'and more and more', 'an excessive number really',
        'of font features could go here'
      })
    end)

  end)

  describe('geometry', function()
    it('Manual page 16 #skip', function()
      assert_deep_equals(
        'hdivide={*,0.9\\paperwidth,*}, vdivide={*,0.9\\paperheight,*}', {
          hdivide = {'*', '0.9\\paperwidth', '*'}, -- < ?
          vdivide = {'*', '0.9\\paperheight', '*'} -- < ?
        })
    end)

    it('Manual page 17 #skip', function()
      assert_deep_equals('a5paper, landscape, twocolumn, twoside,\n' ..
                           'left=2cm, hmarginratio=2:1, includemp, marginparwidth=43pt,\n' ..
                           'bottom=1cm, foot=.7cm, includefoot, textheight=11cm, heightrounded,\n' ..
                           'columnsep=1cm, dvips, verbose', {
        'a5paper',
        'landscape',
        'twocolumn',
        'twoside',
        left = 1234567,
        hmarginratio = '2:1', -- < ?
        'includemp',
        marginparwidth = 1234567,
        bottom = 1234567,
        foot = 1234567,
        'includefoot',
        textheight = 1234567,
        'heightrounded',
        columnsep = 1234567,
        'dvips',
        'verbose'
      })
    end)

  end)

end)
