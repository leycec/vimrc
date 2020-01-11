" --------------------( LICENSE                            )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Git commit message-specific settings applied to all files with basenames
" "COMMIT_EDITMSG".

" ....................{ PREAMBLE                           }....................
" If this plugin has already been loaded for the current buffer, return.
if exists('b:is_our_ftplugin_gitcommit')
    finish
endif

" ....................{ SPELL CHECKING                     }....................
" Unconditionally enable spell checking for all Git commit messages.
setlocal spell

" ....................{ POSTAMBLE                          }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_gitcommit = 1
