all: doc_lua_open

test:
	lua5.1 tests.lua

doc_lua:
	ldoc .

doc_lua_open:
	ldoc .
	xdg-open docs/index.html

.PHONY: all doc_lua doc_lua_open
