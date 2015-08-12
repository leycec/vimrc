" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Python-specific settings.

" ....................{ PREAMBLE                           }....................
" If such plugin has already been loaded for the current buffer, return. Since
" dependencies below may also set such variable, test such variable first.
if exists("b:did_ftplugin")
    finish
endif

" ....................{ CHECKS ~ pathables                 }....................
" If no Python syntax checker supported out-of-the-box by the "vim-watchdogs"
" bundle is in the current ${PATH}, print a non-fatal warning. In such case,
" Python buffers will be syntax-highlighted but *NOT* checked.
if !executable('pyflakes') && !executable('flake8')
    echomsg 'Commands "pyflakes" and "flake8" not found. Expect Python syntax checking to fail.'
endif

" ....................{ POSTAMBLE                          }....................
" Declare such plugin to have been successfully loaded for the current buffer.
let b:did_ftplugin = 1

" --------------------( WASTELANDS                         )--------------------
