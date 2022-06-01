# luakeys

`luakeys` is a Lua module that can parse key-value options like the
TeX packages [keyval](https://www.ctan.org/pkg/keyval),
[kvsetkeys](https://www.ctan.org/pkg/kvsetkeys),
[kvoptions](https://www.ctan.org/pkg/kvoptions),
[xkeyval](https://www.ctan.org/pkg/xkeyval),
[pgfkeys](https://www.ctan.org/pkg/pgfkeys) etc. do. `luakeys`,
however, accompilshes this task entirely, by using the Lua language and
doesn’t rely on TeX. Therefore this package can only be used with the
TeX engine LuaTeX. Since `luakeys` uses
[LPeg](http://www.inf.puc-rio.br/~roberto/lpeg/), the parsing
mechanism should be pretty robust.

## License

Copyright 2021-2022 Josef Friedrich

This work may be distributed and/or modified under the
conditions of the LaTeX Project Public License, either version 1.3c
of this license or (at your option) any later version.
The latest version of this license is in

http://www.latex-project.org/lppl.txt

and version 1.3c or later is part of all distributions of LaTeX
version 2008/05/04 or later.

This work has the LPPL maintenance status `maintained`.

The Current Maintainer of this work is Josef Friedrich.

## Documentation

### Key-value pair definition

```lua
local definition = {
  -- Allow different key names.
  -- or a single string: alias = 'k'
  alias = { 'k', 'ke' },

  -- The key is always included in the result. If no default value is
  -- definied, true is taken as the value.
  always_present = false,

  -- Only values listed in the array table are allowed.
  choices = { 'one', 'two', 'three' },
  data_type = 'string', -- or boolean, integer,
  default = 'value',

  --
  exclusive_group = 'name',

  -- > \g_my_token_list_tl
  l3_tl_set = 'my_token_list',

  -- > \MacroName
  macro = 'MacroName', -- > \MacroName

  -- See http://www.lua.org/manual/5.3/manual.html#6.4.1
  match = '^%d%d%d%d%-%d%d%-%d%d$',

  -- name of the key, can be omitted
  name = 'key',
  opposite_values = { [true] = 'show', [false] = 'hide' },
  process = function(value, result, leftover)
    return value
  end,
  required = true,
  sub_keys = { key_level_2 = { ... } },
}
```

### Parser options (options)

```lua
local options = {
  -- { KEY = 'Value' } -> { key = 'value' }
  case_insensitive_keys = false,

  -- Visit all key-value pairs in the recursive parse tree.
  converter = function(key, value, depth, current_tree, root_tree)
    return key, value
  end,

  -- Automatically convert dimensions into scaled points (1cm -> 1864679).
  -- default: false
  convert_dimensions = false,

  -- Print the result table to the console.
  debug = false,

  -- The default value for naked keys (keys without a value).
  default = true

  -- A table with some default values. The result table is merged with
  -- this table.
  defaults = { key = 'value' },

  -- Key-value pair defintions.
  definitions = { key = { default = 'value' } },

  -- If true, naked keys are converted to values:
  -- { one = true, two = true, three = true } -> { 'one', 'two', 'three' }
  naked_as_value = false,

  -- Throw no error if there are unknown keys.
  no_error = false,

  -- { key = { 'value' } } -> { key = 'value' }
  unpack_single_array_value = false,
}
local result = luakeys.parse('one,two,three', options)
```

## Tasks

### Installing

```
make install
```

### Testing

```
luarocks install busted
busted --exclude-tags=skip test/lua/*.lua
```

or

```
make test
```

### Release a new version

Update version in:

* luakeys-doc.tex
* luakeys-debug.sty
* luakeys.sty

Update copyright in:

* LICENSE
* luakeys-debug.sty
* luakeys-debug.tex
* luakeys.lua
* luakeys.sty
* luakeys.tex
* README.md

Summarize the changes in the luakeys-doc.tex as changes.

Create a new git tag `git tag -sa v0.3`. Prefix the version with “v”.
