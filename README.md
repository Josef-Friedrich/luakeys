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

## Tasks

### Installing

```
make install
```

### Testing

```
luarocks install luaunit
lua test/tests.lua
```

or

```
make test
```
