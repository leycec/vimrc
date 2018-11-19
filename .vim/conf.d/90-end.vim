scriptencoding utf-8
" --------------------( LICENSE                            )--------------------
" Copyright 2015-2018 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Dotfile closure, typically cleaning up after prior logic.

" ....................{ LOCAL                              }....................
" If the current user has a custom Vim dotfile, source this file *AFTER*
" performing all other logic and hence as our penultimate action.
if filereadable(g:our_vimrc_local_file)
    execute 'source ' . fnameescape(g:our_vimrc_local_file)
endif

" --------------------( WASTELANDS                         )--------------------
