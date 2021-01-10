jobname = luakeys
texmf = $(HOME)/texmf
texmftex = $(texmf)/tex/luatex
installdir = $(texmftex)/$(jobname)

all: install doc_lua

install:
	mkdir -p $(installdir)
	cp -f $(jobname).lua $(installdir)

test:
	lua5.3 tests.lua

doc_lua:
	ldoc .

doc_lua_open:
	ldoc .
	xdg-open docs/index.html

.PHONY: all doc_lua doc_lua_open
