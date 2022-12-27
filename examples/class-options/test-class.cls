\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{test-class}[2022/05/26 Test class to access the class options]
\DeclareOption*{} % suppresses the warning: LaTeX Warning: Unused global option(s):
\ProcessOptions\relax
\RequirePackage{luakeys}

% Using the macro \LuakeysSaveClassOptions
\LuakeysSaveClassOptions{test-class}
\directlua{
  luakeys.debug(luakeys.parse(luakeys.get('test-class')))
}

% Low level approach
\directlua{
  luakeys.debug(luakeys.parse('\@classoptionslist'))
}

\LoadClass{article}
