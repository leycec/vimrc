" --------------------( LICENSE                           )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                          )--------------------
" reStructuredText-specific syntax settings.

" ....................{ SPELLING                          }....................
" Forcefully enable highlighting of spelling mistakes. For unknown reasons, the
" "riv.vim" plugin implementing core reStructuredText support contains the
" following insane conditional:
"
"     if !exists("g:_riv_including_python_rst") && has("spell")
"         " Enable spelling on the whole file if we're not being included to parse
"         " docstrings
"         syn spell toplevel
"     endif
"
" That fails, as the "g:_riv_including_python_rst" global inexplicably exists
" even when *NOT* parsing docstrings. To resolve this, we simply replicate the
" body of that conditional here. *shrug*
syn spell toplevel
