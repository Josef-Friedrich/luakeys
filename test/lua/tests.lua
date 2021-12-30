local luaunit = require('luaunit')
local luakeys = require('luakeys')
-- luarocks install inspect
-- local inspect = require('inspect')

local parse = luakeys.parse

local assertEquals = luaunit.assertEquals

function test_empty_string()
  assertEquals(true, true)
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

function test_array()
  assertEquals(parse('t={a,b},z={{a,b},{c,d}}'),
               {t = {'a', 'b'}, z = {{'a', 'b'}, {'c', 'd'}}})
  assertEquals(parse('{one,two,tree}'), {{'one', 'two', 'tree'}})
  assertEquals(parse('{one,two,tree={four}}'), {{'one', 'two', tree = 'four'}})
  assertEquals(parse('{{{one}}}'), {{{'one'}}})

end

os.exit(luaunit.LuaUnit.run())
