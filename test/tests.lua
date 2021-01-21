local luaunit = require('luaunit')
local luakeys = require('luakeys')
-- luarocks install inspect
-- local inspect = require('inspect')

local example = [[
  show,
  hide,
  key with spaces = String without quotes,
  string="String with double quotes: ,{}=",
  dimension = 1cm,
  number = 2,
  float = 1.2,
  list = {one,two,three},
  key value list = {one=one,two=two,three=three},
  nested key = {
    nested key 2= {
      key = value,
    },
  },
]]

local parse = luakeys.parse

local assertEquals = luaunit.assertEquals

function test_empty_string()
  assertEquals(true, true)
end

function test_datatype_number()
  local assert_number = function(input, output)
    assertEquals(parse('key=' .. input), {key = output})
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

function test_datatypes()
  local function assert_type(value, expected_type)
    local result = luakeys.parse('key='.. value)
    luaunit.assert_equals(type(result.key), expected_type)
  end

  assert_type('1', 'number')
  assert_type(' 1 ', 'number')
  --assert_type('1 lol', 'string')
  --assert_type(' 1 lol ', 'string')
  assert_type('1.1', 'number')
  assert_type('1cm', 'number')
  assert_type('-1.4cm', 'number')
  assert_type('-0.4pt', 'number')
  assert_type('true', 'boolean')
  assert_type('false', 'boolean')
  assert_type('FALSE', 'boolean')
  assert_type('"lol"', 'string')
end

function test_datatype_boolean()
  local function assert_boolean(boolean_string, value)
    assertEquals(parse('key=' .. boolean_string), {key = value})
  end
  assert_boolean('true', true)
  assert_boolean('TRUE', true)
  assert_boolean('True', true)

  assert_boolean('false', false)
  assert_boolean('FALSE', false)
  assert_boolean('False', false)
end

function test_datatype_string()
  local function assert_string(input, value)
    assertEquals(parse('string=' .. input), {string = value})
  end
  assert_string('"1"', '1')
  assert_string('"1\\\"test\\\"2"', '1\\\"test\\\"2')
  assert_string('"1,2"', '1,2')
end

function test_datatype_dimension()
  local function assert_dimension(value)
    local result = luakeys.parse('key='.. value)
    luaunit.assert_equals(result.key, 1234567)
  end

  assert_dimension('1cm')
  assert_dimension('-1cm')
  assert_dimension('+1cm')
  assert_dimension('1 cm')
  assert_dimension('- 1 cm')
  assert_dimension('+ 1 cm')
  assert_dimension('1CM')
end

function test_white_spaces()
  assertEquals(parse('integer=1'), {integer = 1})
  assertEquals(parse('integer = 2'), {integer = 2})
  assertEquals(parse('integer\t=\t3'), {integer = 3})
  assertEquals(parse('integer\n=\n4'), {integer = 4})
  assertEquals(parse('integer \t\n= \t\n5 , boolean=false'),
               {integer = 5, boolean = false})
  assertEquals(parse('integer=1 , boolean=false'),
               {integer = 1, boolean = false})
  assertEquals(parse('integer \t\n= \t\n1 \t\n, \t\nboolean \t\n= \t\nfalse'),
               {integer = 1, boolean = false})
end

function test_multiple_keys()
  assertEquals(parse('integer=1,boolean=false'), {integer = 1, boolean = false})
  assertEquals(parse('integer=1 , boolean=false'),
               {integer = 1, boolean = false})
end

function test_edge_cases()
  assertEquals(parse(''), {})
  assertEquals(parse(',,'), {})
  assertEquals(parse(',,,'), {})
  assertEquals(parse(', , ,'), {})
  assertEquals(parse(' ,'), {})
  assertEquals(parse(', '), {})
end

function test_keys()
  assertEquals(parse('umlaute öäü=1'), {["umlaute öäü"] = 1})
  assertEquals(parse('2=2'), {[2] = 2})
  assertEquals(parse('under_score=1'), {["under_score"] = 1})
  assertEquals(parse('true=true'), {[true] = true})

end

function test_duplicate_keys()
  assertEquals(parse('integer=1,integer=2'), {integer = 2})
  assertEquals(parse('integer=1 , integer=2'), {integer = 2})
end

function test_all()
  assertEquals(parse('one,two,three'), {'one', 'two', 'three'})
  assertEquals(parse('1,2,3'), {1, 2, 3})
  assertEquals(parse('level1={level2={level3=level3}}'),
               {level1 = {level2 = {level3 = 'level3'}}})
  assertEquals(parse('string = without \'quotes\''),
               {string = "without \'quotes\'"})
  assertEquals(parse('string = "with quotes: ,={}"'),
               {string = 'with quotes: ,={}'})
  assertEquals(parse('number = -0.123'), {number = -0.123})
end

function test_only_values()
  assertEquals(parse('-1.1,text,-1cm,True'), {-1.1, 'text', 1234567, true})
  assertEquals(parse('one,two,three'), {'one', 'two', 'three'})

end

function test_tikz()
  -- tikz manual page 330
  assertEquals(parse('matrix of math nodes,\n' ..
                       'column sep={2cm,between origins},\n' ..
                       'row sep={3cm,between origins},\n' ..
                       'nodes={circle, draw, minimum size=7.5mm}'), {
    'matrix of math nodes',
    ['column sep'] = {1234567, 'between origins'},
    nodes = {'circle', 'draw', ['minimum size'] = 1234567},
    ['row sep'] = {1234567, 'between origins'}
  })

  -- page 241
  assertEquals(parse('every node/.style=draw'), {['every node/.style'] = 'draw'})

  -- page 237
  assertEquals(luakeys.parse(
                 'fill=yellow!80!black,text width=3cm,align=flush center'), {
    align = 'flush center',
    fill = 'yellow!80!black',
    ['text width'] = 1234567
  })

end

function test_hyperref()
  -- manual page 6
  assertEquals(parse('pdfborder={0 0 0}'), {pdfborder = {0, 0, 0}})

  assertEquals(parse('backref,\npdfpagemode=FullScreen,\ncolorlinks=true'),
               {'backref', colorlinks = true, pdfpagemode = 'FullScreen'})

  assertEquals(parse('backref,\npdfpagemode=FullScreen,\ncolorlinks=true'),
               {'backref', colorlinks = true, pdfpagemode = 'FullScreen'})

  -- page 15
  assertEquals(parse(
                 'pdfinfo={\nTitle={My Title},\nSubject={My Subject},\nNewKey={Foobar},\n}'),
               {
    pdfinfo = {NewKey = 'Foobar', Subject = 'My Subject', Title = 'My Title'}
  })
end

function test_geometry()
  -- manual page 17
  assertEquals(parse('a5paper, landscape, twocolumn, twoside,\n' ..
                       'left=2cm, hmarginratio=2:1, includemp, marginparwidth=43pt,\n' ..
                       'bottom=1cm, foot=.7cm, includefoot, textheight=11cm, heightrounded,\n' ..
                       'columnsep=1cm, dvips, verbose'), {
    'a5paper',
    'landscape',
    'twocolumn',
    'twoside',
    ':1', -- ??? hmarginratio = '2:1'
    'includemp',
    'includefoot',
    'heightrounded',
    'dvips',
    'verbose',
    bottom = 1234567,
    columnsep = 1234567,
    foot = 1234567,
    hmarginratio = 2,
    left = 1234567,
    marginparwidth = 1234567,
    textheight = 1234567
  })

  assertEquals(parse(
                 'hdivide={*,0.9\\paperwidth,*}, vdivide={*,0.9\\paperheight,*}'),
               {
    hdivide = {'*', 0.9, '\\paperwidth', '*'}, -- ??? '0.9\\paperwidth',???
    vdivide = {'*', 0.9, '\\paperheight', '*'}
  })

end

function test_fontspec()
  -- manual page 11
  assertEquals(parse('Extension = .ttf ,\n' .. 'UprightFont = CharisSILR,\n' ..
                       'BoldFont = CharisSILB,\n' ..
                       'ItalicFont = CharisSILI,\n' ..
                       'BoldItalicFont = CharisSILBI,\n' ..
                       '% <any other desired options>\n'), {
    '% <any other desired options>', -- ???
    BoldFont = 'CharisSILB',
    BoldItalicFont = 'CharisSILBI',
    Extension = '.ttf',
    ItalicFont = 'CharisSILI',
    UprightFont = 'CharisSILR'
  })

  -- 17
  assertEquals(parse('Extension = .otf ,\n' .. 'UprightFont = *-Light ,\n' ..
                       'BoldFont = *-Regular ,\n' ..
                       'FontFace = {k}{n}{*-Black} ,'), {
    Extension = '.otf',
    UprightFont = '*-Light',
    BoldFont = '*-Regular',
    FontFace = 'k' -- ???
  })

  -- 18
  assertEquals(parse('lots and lots ,\n' .. 'and more and more ,\n' ..
                       'an excessive number really ,\n' ..
                       'of font features could go here\n'), {
    'lots and lots', 'and more and more', 'an excessive number really',
    'of font features could go here'
  })
end

function test_function_stringify()
  luakeys.print(luakeys.parse(example))
end

function test_function_render()
  assertEquals(luakeys.render(luakeys.parse('key')), 'key,')

  assertEquals(luakeys.render(luakeys.parse('level1={level2={level3=value}}')),
               'level1={level2={level3=value,},},')

  assertEquals(luakeys.render(luakeys.parse('1')), '1,')
  assertEquals(luakeys.render(luakeys.parse('1cm')), '1234567,')
  assertEquals(luakeys.render(luakeys.parse('TRUE')), 'true,')
  assertEquals(luakeys.render(luakeys.parse('one,two,three')), 'one,two,three,')

end

os.exit(luaunit.LuaUnit.run())
