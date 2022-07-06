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

### Key-value pair definitions

```lua
local defs = {
  key = {
    -- Allow different key names.
    -- or a single string: alias = 'k'
    alias = { 'k', 'ke' },

    -- The key is always included in the result. If no default value is
    -- definied, true is taken as the value.
    always_present = false,

    -- Only values listed in the array table are allowed.
    choices = { 'one', 'two', 'three' },

    -- Possible data types: boolean, dimension, integer, number, string
    data_type = 'string',

    default = true,

    -- The key belongs to a mutually exclusive group of keys.
    exclusive_group = 'name',

    -- > \MacroName
    macro = 'MacroName', -- > \MacroName

    -- See http://www.lua.org/manual/5.3/manual.html#6.4.1
    match = '^%d%d%d%d%-%d%d%-%d%d$',

    -- The name of the key, can be omitted
    name = 'key',
    opposite_keys = { [true] = 'show', [false] = 'hide' },
    process = function(value, input, result, unknown)
      return value
    end,
    required = true,
    sub_keys = { key_level_2 = { } },
  }
}
```

### Parser options (opts)

```lua
local opts = {
  -- Automatically convert dimensions into scaled points (1cm -> 1864679).
  convert_dimensions = false,

  -- Print the result table to the console.
  debug = false,

  -- The default value for naked keys (keys without a value).
  default = true,

  -- A table with some default values. The result table is merged with
  -- this table.
  defaults = { key = 'value' },

  -- Key-value pair definitions.
  defs = { key = { default = 'value' } },

  -- lower, snake, upper
  format_keys = { 'snake' },

  -- Listed in the order of execution
  hooks = {
    kv_string = function(kv_string)
      return kv_string
    end,

    -- Visit all key-value pairs recursively.
    keys_before_opts = function(key, value, depth, current, result)
      return key, value
    end,

    -- Visit the result table.
    result_before_opts = function(result)
    end,

    -- Visit all key-value pairs recursively.
    keys_before_def = function(key, value, depth, current, result)
      return key, value
    end,

    -- Visit the result table.
    result_before_def = function(result)
    end,

    -- Visit all key-value pairs recursively.
    keys = function(key, value, depth, current, result)
      return key, value
    end,

    -- Visit the result table.
    result = function(result)
    end,
  },

  -- If true, naked keys are converted to values:
  -- { one = true, two = true, three = true } -> { 'one', 'two', 'three' }
  naked_as_value = false,

  -- Throw no error if there are unknown keys.
  no_error = false,

  -- { key = { 'value' } } -> { key = 'value' }
  unpack = false,
}
local result = luakeys.parse('one,two,three', opts)
```

## Development

`luakeys` is developed using the
[Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
extension in Visual Studio Code. This extension understands the [EmmyLua
annotations](https://github.com/sumneko/lua-language-server/wiki/EmmyLua-Annotations).
The Lua source code documentation is generated with
[LDoc](https://stevedonovan.github.io/ldoc/manual/doc.md.html).

The Lua code is automatically formatted with the help of the
[LuaFormatter](https://github.com/Koihik/LuaFormatter).

## Tasks

### Installing

```
make install
```

### Testing

The framework [busted](https://github.com/Olivine-Labs/busted) is used
for the tests.

```
luarocks install busted
busted --exclude-tags=skip test/lua/*.lua
```

or

```
make test
```

### Release a new version

This project uses [semantic versioning](https://semver.org).

Update version in:

* luakeys-doc.tex
* luakeys-debug.sty
* luakeys.sty
* luakeys.lua

Update copyright in:

* LICENSE
* luakeys-debug.sty
* luakeys-debug.tex
* luakeys.lua
* luakeys.sty
* luakeys.tex
* README.md

Summarize the changes in the luakeys-doc.tex as changes.

Create a new git tag `git tag -sa 0.7.0`.
