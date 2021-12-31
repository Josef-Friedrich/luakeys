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
