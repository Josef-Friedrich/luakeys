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

test: install test_lua test_examples test_tex doc_pdf

test_lua:
	busted --lua=/usr/bin/lua5.3 --exclude-tags=skip tests/lua/test-*.lua

test_examples: test_examples_lua test_examples_plain test_examples_latex
test_examples_lua:
	busted --pattern "**/*.lua" examples
test_examples_plain:
	find examples -iname "*plain.tex" -exec luatex --output-dir=examples {} \;
test_examples_latex:
	find examples -iname "*latex.tex" -exec latexmk -lualatex -cd --output-directory=examples {} \;

test_tex: test_tex_plain test_tex_latex
test_tex_plain:
	find tests/tex/plain -iname "*.tex" -exec luatex --output-dir=tests/tex/plain {} \;
test_tex_latex:
	find tests/tex/latex -iname "*.tex" -exec lualatex --output-dir=tests/tex/latex {} \;

doc: doc_pdf

doc_pdf:
	lualatex --shell-escape luakeys-doc.tex
	makeindex -s gglo.ist -o luakeys-doc.gls luakeys-doc.glo
	makeindex -s gind.ist -o luakeys-doc.ind luakeys-doc.idx
	lualatex --shell-escape luakeys-doc.tex
	mkdir -p $(texmf)/doc
	cp luakeys-doc.pdf $(texmf)/doc/$(jobname).pdf

ctan: doc_pdf
	rm -rf $(jobname).tar.gz
	rm -rf $(jobname)/
	mkdir $(jobname)
	cp -f README.md $(jobname)/
	cp -f $(jobname).lua $(jobname)/
	cp -f $(jobname).sty $(jobname)/
	cp -f $(jobname).tex $(jobname)/
	cp -f luakeys-doc.tex $(jobname)/
	cp -f luakeys-doc.pdf $(jobname)/$(jobname).pdf
	cp -f $(jobname)-debug.tex $(jobname)/
	cp -f $(jobname)-debug.sty $(jobname)/
	tar cvfz $(jobname).tar.gz $(jobname)
	rm -rf $(jobname)

clean:
	git clean -fdx

.PHONY: all doc_lua doc_lua_open test test_lua test_tex test_tex_plain test_text_latex test_examples_lua
