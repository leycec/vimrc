" --------------------( LICENSE                            )--------------------
" Copyright 2015-2017 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Shell script-specific settings ambiguously applicable to all Bash, Bourne, and
" Korn buffers.

" ....................{ PREAMBLE                           }....................
" If this plugin has already been loaded for the current buffer, return.
if exists("b:is_our_ftplugin")
    finish
endif

" ....................{ CHECKS                             }....................
" If our preferred syntax checker for shell scripts supported out-of-the-box by
" the "vim-watchdogs" bundle is *NOT* in the current ${PATH}, print a warning.
" In this case, shell buffers will be syntax-highlighted but *NOT* checked.
if !executable('shellcheck')
    echomsg 'Command "shellcheck" not found. Expect shell script syntax checking to fail.'
endif

" ....................{ POSTAMBLE                          }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin = 1
