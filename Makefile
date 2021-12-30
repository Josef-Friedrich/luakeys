jobname = luakeys
texmf = $(HOME)/texmf
texmftex = $(texmf)/tex/luatex
installdir = $(texmftex)/$(jobname)

all: install doc_lua

install:
	-tlmgr uninstall --force luakeys
	mkdir -p $(installdir)
	cp -f $(jobname).lua $(installdir)
	cp -f $(jobname).sty $(installdir)
	cp -f $(jobname).tex $(installdir)
	cp -f $(jobname)-debug.tex $(installdir)
	cp -f $(jobname)-debug.sty $(installdir)

test: install
	busted --exclude-tags=skip test/lua/*.lua

doc: doc_pdf doc_lua

doc_pdf:
	lualatex --shell-escape $(jobname)-doc.tex
	makeindex -s gglo.ist -o $(jobname)-doc.gls $(jobname)-doc.glo
	makeindex -s gind.ist -o $(jobname)-doc.ind $(jobname)-doc.idx
	lualatex --shell-escape $(jobname)-doc.tex
	sleep 1
	mkdir -p $(texmf)/doc
	cp $(jobname)-doc.pdf $(texmf)/doc

doc_lua:
	ldoc .

doc_lua_open:
	ldoc .
	xdg-open docs/index.html

ctan: doc_pdf
	rm -rf $(jobname).tar.gz
	rm -rf $(jobname)/
	mkdir $(jobname)
	cp -f README.md $(jobname)/
	cp -f $(jobname)-doc.tex $(jobname)/
	cp -f $(jobname).lua $(jobname)/
	cp -f $(jobname).sty $(jobname)/
	cp -f $(jobname).tex $(jobname)/
	cp -f $(jobname)-doc.pdf $(jobname)/
	cp -f $(jobname)-debug.tex $(jobname)/
	cp -f $(jobname)-debug.sty $(jobname)/
	tar cvfz $(jobname).tar.gz $(jobname)
	rm -rf $(jobname)

clean:
	git clean -fdx

.PHONY: all doc_lua doc_lua_open test
