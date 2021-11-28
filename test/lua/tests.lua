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
                       'BoldFont = *-Regular ,\n' .. 'FontFace = {*-Black} ,'),
               {
    Extension = '.otf',
    UprightFont = '*-Light',
    BoldFont = '*-Regular',
    FontFace = '*-Black' -- ???
  })

  --   {
  --     "n",
  --     "*-Black",
  --     BoldFont="*-Regular",
  --     Extension=".otf",
  --     FontFace="k",
  --     UprightFont="*-Light"
  -- }

  -- {BoldFont="*-Regular", Extension=".otf", FontFace="k", UprightFont="*-Light"}

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

function test_array()
  assertEquals(parse('t={a,b},z={{a,b},{c,d}}'),
               {t = {'a', 'b'}, z = {{'a', 'b'}, {'c', 'd'}}})
  assertEquals(parse('{one,two,tree}'), {{'one', 'two', 'tree'}})
  assertEquals(parse('{one,two,tree={four}}'), {{'one', 'two', tree = 'four'}})
  assertEquals(parse('{{{one}}}'), {{{'one'}}})

end

os.exit(luaunit.LuaUnit.run())
