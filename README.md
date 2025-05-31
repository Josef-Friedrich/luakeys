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

## Current version

2024/09/29 v0.15

## License

Copyright (C) 2021-2025 by Josef Friedrich <josef@friedrich.rocks>
------------------------------------------------------------------------
This work may be distributed and/or modified under the conditions of
the LaTeX Project Public License, either version 1.3c of this license
or (at your option) any later version.  The latest version of this
license is in:

  http://www.latex-project.org/lppl.txt

and version 1.3c or later is part of all distributions of LaTeX
version 2008/05/04 or later.

## Maintainer

Josef Friedrich <josef@friedrich.rocks>

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

    -- Possible data types:
    -- any, boolean, dimension, integer, number, string, list
    data_type = 'string',

    -- To provide a default value for each naked key individually.
    default = true,

    -- Can serve as a comment.
    description = 'Describe your key-value pair.',

    -- The key belongs to a mutually exclusive group of keys.
    exclusive_group = 'name',

    -- > \MacroName
    macro = 'MacroName', -- > \MacroName

    -- See http://www.lua.org/manual/5.3/manual.html#6.4.1
    match = '^%d%d%d%d%-%d%d%-%d%d$',

    -- The name of the key, can be omitted
    name = 'key',

    -- Convert opposite (naked) keys
    -- into a boolean value and store this boolean under a target key:
    --   show -> opposite_keys = true
    --   hide -> opposite_keys = false
    -- Short form: opposite_keys = { 'show', 'hide' }
    opposite_keys = { [true] = 'show', [false] = 'hide' },

    -- Pick a value by its data type:
    -- 'any', 'string', 'number', 'dimension', 'integer', 'boolean'.
    pick = false, -- ’false’ disables the picking.

    -- A function whose return value is passed to the key.
    process = function(value, input, result, unknown)
      return value
    end,

    -- To enforce that a key must be specified.
    required = true,

    -- To build nested key-value pair definitions.
    sub_keys = { key_level_2 = { } },
  }
}
```

### Parser options (opts)

```lua
local opts = {
  -- Result table that is filled with each call of the parse function.
  accumulated_result = accumulated_result,

  -- Configure the delimiter that assigns a value to a key.
  assignment_operator = '=',

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

  -- Specify the strings that are recognized as boolean false values.
  false_aliases = { 'false', 'FALSE', 'False' },

  -- lower, snake, upper
  format_keys = { 'snake' },

  -- Configure the delimiter that marks the beginning of a group.
  group_begin = '{',

  -- Configure the delimiter that marks the end of a group.
  group_end = '}',

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

  invert_flag = '!',

  -- Configure the delimiter that separates list items from each other.
  list_separator = ',',

  -- If true, naked keys are converted to values:
  -- { one = true, two = true, three = true } -> { 'one', 'two', 'three' }
  naked_as_value = false,

  -- Throw no error if there are unknown keys.
  no_error = false,

  -- Configure the delimiter that marks the beginning of a string.
  quotation_begin = '"',

  -- Configure the delimiter that marks the end of a string.
  quotation_end = '"',

  -- Specify the strings that are recognized as boolean true values.
  true_aliases = { 'true', 'TRUE', 'True' },

  -- { key = { 'value' } } -> { key = 'value' }
  unpack = false,
}
local result = luakeys.parse('one,two,three', opts)
```

## Development

`luakeys` is developed using the
[Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
extension in Visual Studio Code. This extension understands the modified
[EmmyLua annotations](https://github.com/sumneko/lua-language-server/wiki/Annotations).
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
