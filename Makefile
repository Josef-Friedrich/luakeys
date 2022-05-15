jobname = luakeys
texmf = $(HOME)/texmf
texmftex = $(texmf)/tex/luatex
installdir = $(texmftex)/$(jobname)

all: install doc_lua

install: uninstall_texlive install_quick

uninstall_texlive:
	-tlmgr uninstall --force luakeys

install_quick:
	mkdir -p $(installdir)
	cp -f $(jobname).lua $(installdir)
	cp -f $(jobname).sty $(installdir)
	cp -f $(jobname).tex $(installdir)
	cp -f $(jobname)-debug.tex $(installdir)
	cp -f $(jobname)-debug.sty $(installdir)

test: install test_lua test_tex doc_pdf

test_lua:
	busted --lua=/usr/bin/lua5.3 --exclude-tags=skip test/lua/test-*.lua

test_tex: test_tex_plain test_tex_latex

test_tex_plain:
	find test/tex/plain -iname "*.tex" -exec luatex --output-dir=test/tex/plain {} \;
test_tex_latex:
	find test/tex/latex -iname "*.tex" -exec lualatex --output-dir=test/tex/latex {} \;

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

.PHONY: all doc_lua doc_lua_open test test_lua test_tex test_tex_plain test_text_latex
