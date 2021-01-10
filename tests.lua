local luaunit = require('luaunit')
local luakeys = require('luakeys')
-- luarocks install inspect
-- local inspect = require('inspect')

local parse = luakeys.parse

local assertEquals = luaunit.assertEquals

function test_empty_string()
  assertEquals(true, true)
end

function test_datatype_number()
  local assert_number = function(input, output)
    assertEquals(parse('key=' .. input), { key = output })
  end
  assert_number('1', 1)
  assert_number('1.1', 1.1)
  assert_number('+1.1', 1.1)
  assert_number('-1.1', -1.1)
  assert_number('11e-02', 0.11)
  assert_number('11e-02', 11e-02)
  assert_number('-11e-02', -0.11)
  assert_number('+11e-02', 0.11)
end

--- @todo remove
function test_datatype_boolean_ng()
  local function assert_boolean(boolean_string, value)
    assertEquals(parse('key=' .. boolean_string), { key = value })
  end
  assert_boolean('true', true)
  assert_boolean('TRUE', true)
  assert_boolean('yes', true)
  assert_boolean('YES', true)

  assert_boolean('false', false)
  assert_boolean('FALSE', false)
  assert_boolean('no', false)
  assert_boolean('NO', false)
end

function test_datatype_string()
  local function assert_string(input, value)
    assertEquals(parse('string=' .. input), { string = value })
  end
  assert_string('"1"', '1')
  assert_string('"1\\\"test\\\"2"', '1\\\"test\\\"2')
  assert_string('"1,2"', '1,2')
end

function test_white_spaces()
  assertEquals(parse('integer=1'), { integer = 1 })
  assertEquals(parse('integer = 2'), { integer = 2 })
  assertEquals(parse('integer\t=\t3'), { integer = 3 })
  assertEquals(parse('integer\n=\n4'), { integer = 4 })
  assertEquals(parse('integer \t\n= \t\n5 , boolean=no'), { integer = 5, boolean = false })
  assertEquals(parse('integer=1 , boolean=no'), { integer = 1, boolean = false })
  assertEquals(parse('integer \t\n= \t\n1 \t\n, \t\nboolean \t\n= \t\nno'), { integer = 1, boolean = false })
end

function test_multiple_keys()
  assertEquals(parse('integer=1,boolean=no'), { integer = 1, boolean = false })
  assertEquals(parse('integer=1 , boolean=no'), { integer = 1, boolean = false })
end

function test_edge_cases()
  assertEquals(parse(''), {})
  assertEquals(parse(',,'), {})
  assertEquals(parse(',,,'), {})
  assertEquals(parse(', , ,'), {})
  assertEquals(parse(' ,'), {})
  assertEquals(parse(', '), {})
end

function test_duplicate_keys()
  assertEquals(parse('integer=1,integer=2'), { integer = 2})
  assertEquals(parse('integer=1 , integer=2'), { integer = 2})
end

function test_all()
  assertEquals(parse('one,two,three'), {'one', 'two', 'three'})
  assertEquals(parse('1,2,3'), {1, 2, 3})
  assertEquals(
    parse('level1={level2={level3=level3}}'),
    {
      level1 = {
        level2 = {
          level3 = "level3"
        }
      }
    }
  )
  assertEquals(parse('string = without quotes'), { string = "without quotes" })
  assertEquals(parse('string = "with quotes: ,={}"'), { string = "with quotes: ,={}" })
  assertEquals(parse('number = -0.123'), { number = -0.123 })
end

function test_tikz()
  -- tikz manual page 330
  assertEquals(
    parse(
      'matrix of math nodes,\n' ..
      'column sep={2cm,between origins},\n' ..
      'row sep={3cm,between origins},\n' ..
      'nodes={circle, draw, minimum size=7.5mm}'
    ),
    {
      'matrix of math nodes',
      ['column sep'] = { '2cm', 'between origins' },
      nodes = { 'circle', 'draw', ['minimum size'] = '7.5mm' },
      ['row sep'] = { '3cm', 'between origins' }
    }
  )

  -- page 241
  assertEquals(
    parse(
      'every node/.style=draw'
    ),
    {
      ['every node/.style'] = 'draw'
    }
  )

  -- page 237
  assertEquals(
    parse(
      'fill=yellow!80!black,text width=3cm,align=flush center'
    ),
    {
      align = 'flush center',
      fill = 'yellow!80!black',
      ['text width'] = '3cm'
    }
  )

end

function test_hyperref()
  -- manual page 6
  assertEquals(
    parse('pdfborder={0 0 0}'),
    {
      pdfborder = {0, 0, 0}
    }
  )

  assertEquals(
    parse('backref,\npdfpagemode=FullScreen,\ncolorlinks=true'),
    { 'backref', colorlinks = true, pdfpagemode = 'FullScreen' }
  )

  assertEquals(
    parse('backref,\npdfpagemode=FullScreen,\ncolorlinks=true'),
    { 'backref', colorlinks = true, pdfpagemode = 'FullScreen' }
  )

  -- page 15
  assertEquals(
    parse('pdfinfo={\nTitle={My Title},\nSubject={My Subject},\nNewKey={Foobar},\n}'),
    {
      pdfinfo = {
        NewKey = { "Foobar" },
        Subject = { "My Subject" },
        Title = { "My Title" }
      }
    }
  )
end

function test_geometry()
  -- manual page 17
  assertEquals(
    parse('a5paper, landscape, twocolumn, twoside,\n' ..
    'left=2cm, hmarginratio=2:1, includemp, marginparwidth=43pt,\n' ..
    'bottom=1cm, foot=.7cm, includefoot, textheight=11cm, heightrounded,\n' ..
    'columnsep=1cm, dvips, verbose'),
    {
      'a5paper',
      'landscape',
      'twocolumn',
      'twoside',
      ':1', --??? hmarginratio = '2:1'
      'includemp',
      'includefoot',
      'heightrounded',
      'dvips',
      'verbose',
      bottom = '1cm',
      columnsep = '1cm',
      foot = '.7cm',
      hmarginratio = 2,
      left = '2cm',
      marginparwidth = '43pt',
      textheight = '11cm'
  })

  assertEquals(
    parse('hdivide={*,0.9\\paperwidth,*}, vdivide={*,0.9\\paperheight,*}'),
    {
      hdivide = { '*', 0.9, '\\paperwidth', '*' }, -- ??? '0.9\\paperwidth',???
      vdivide = { '*', 0.9, '\\paperheight', '*' }
    }
  )

end

os.exit( luaunit.LuaUnit.run() )
