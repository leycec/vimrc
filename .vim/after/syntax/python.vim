" --------------------( LICENSE                           )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                          )--------------------
" Python-specific syntax settings.

" ....................{ SPELLING                          }....................
"FIXME: Frankly, this is extraordinarily annoying. We've squandered far too
"time on this already. Consider authoring a plugin if no one else has. *sigh*
" Avoid highlighting words guaranteed *NEVER* to be misspelled as misspelled.
" Dismantled, this is:
" * "\{-}", the non-greedy variant of the "*" operator.
" * "\{-1,}", the non-greedy variant of the "+" operator.
"
" See also:
" * The "SPELLING" subsection of "~/vim/conf.d/30-usage.vim".
" * The following self-StackOverflow answer:
"     https://vi.stackexchange.com/a/24534/16249

" Avoid spell checking URIs.
syntax match NoSpellPythonUri
  \ /\v\w+:\/\/[^[:space:]]+/ transparent
  \ contained containedin=pythonComment,python.*String contains=@NoSpell

" Avoid spell checking both CamelCase-formatted identifiers and uppercase
" identifiers. Since most languages (excluding Raku) prohibit Unicode in
" identifiers, these matches are intentionally confined to ASCII codepoints
" (e.g., "[A-Z]" rather than "[[:upper:]]").
syntax match NoSpellPythonCaps
  \ /\v<[A-Z]([A-Z0-9]{-1,}|[a-z0-9]+[A-Z0-9].{-})>/ transparent
  \ contained containedin=pythonComment,python.*String contains=@NoSpell

"FIXME: For unknown reasons, enabling this and *ONLY* this "syntax" statement
"causes subtle (but horrible) failures across "python-mode" indentation and
"syntax highlighting. While lamentable, we need "python-mode" more than we need
"to avoid spell checking snake_case-formatted identifiers. See also this
"currently unresolved upstream issue:
"    https://github.com/python-mode/python-mode/issues/1083

" " Avoid spell checking snake_case-formatted identifiers.
" syntax match NoSpellPythonSnake
"   \ /\v<\w+_.{-1,}>/ transparent
"   \ contained containedin=pythonComment,python.*String contains=@NoSpell

" Avoid spell checking "@"-prefixed identifiers.
syntax match NoSpellPythonDecorator
  \ /\v\@[a-zA-Z].{-}>/ transparent
  \ contained containedin=pythonComment,python.*String contains=@NoSpell

" Avoid spell checking ":"-delimited substrings.
syntax match NoSpellPythonColons
  \ /\v:[^:]+:/ transparent
  \ contained containedin=pythonComment,python.*String contains=@NoSpell

" Avoid spell checking "`"-delimited substrings.
syntax match NoSpellPythonTicks
  \ /\v`[^`]+`/ transparent
  \ contained containedin=pythonComment,python.*String contains=@NoSpell

" Avoid spell checking '"'-delimited filetyped filenames matched as a
" double-quoted substring containing a filename prefix, a period, and one to
" four characters comprising a filetype.
syntax match NoSpellPythonPath
  \ /\v"[^"]+.[^"]{1,4}"/ transparent
  \ contained containedin=pythonComment,python.*String contains=@NoSpell

"FIXME: Seemingly unneeded. Perhaps Vim now ignores acronyms by default?
" syntax match NoSpellAcronymPython '\<\(\u\|\d\)\{3,}s\?\>' transparent
"   \ contained containedin=pythonComment,python.*String contains=@NoSpell
