" --------------------( LICENSE                           )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                          )--------------------
" Python-specific settings.

" ....................{ SPELLING                          }....................
" Avoid highlighting words guaranteed *NEVER* to be misspelled as misspelled.
" See also:
" * The "SPELLING" subsection of "~/vim/conf.d/30-usage.vim".
" * The following self-StackOverflow answer:
"     https://vi.stackexchange.com/a/24534/16249
syntax match NoSpellUriPython '\w\+:\/\/[^[:space:]]\+' transparent contained containedin=pythonComment,python.*String contains=@NoSpell

"FIXME: Seemingly unneeded. Perhaps Vim now ignores acronyms by default?
" syntax match NoSpellAcronymPython '\<\(\u\|\d\)\{3,}s\?\>'  transparent contains=@NoSpell contained containedin=pythonComment,pythonString,,pythonDocstring
