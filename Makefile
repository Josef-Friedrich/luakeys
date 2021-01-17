jobname = luakeys
texmf = $(HOME)/texmf
texmftex = $(texmf)/tex/luatex
installdir = $(texmftex)/$(jobname)

all: install doc_lua

install:
	mkdir -p $(installdir)
	cp -f $(jobname).lua $(installdir)
	cp -f $(jobname)-debug.tex $(installdir)
	cp -f $(jobname)-debug.sty $(installdir)

test: install
	lua5.3 test/tests.lua

doc: doc_pdf doc_lua

doc_pdf:
	lualatex --shell-escape documentation.tex
	makeindex -s gglo.ist -o documentation.gls documentation.glo
	makeindex -s gind.ist -o documentation.ind documentation.idx
	lualatex --shell-escape documentation.tex
	mkdir -p $(texmf)/doc
	mv documentation.pdf $(jobname).pdf
	cp $(jobname).pdf $(texmf)/doc

doc_lua:
	ldoc .

doc_lua_open:
	ldoc .
	xdg-open docs/index.html

ctan: doc_pdf
	rm -rf $(jobname)
	mkdir $(jobname)
	cp -f README.md $(jobname)/
	cp -f $(jobname).lua $(jobname)/
	cp -f $(jobname).pdf $(jobname)/
	cp -f $(jobname)-debug.tex $(jobname)/
	cp -f $(jobname)-debug.sty $(jobname)/
	tar cvfz $(jobname).tar.gz $(jobname)
	rm -rf $(jobname)

.PHONY: all doc_lua doc_lua_open test
