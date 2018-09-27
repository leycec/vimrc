scriptencoding utf-8
" --------------------( LICENSE                           )--------------------
" Copyright 2015-2018 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                          )--------------------
" Dotfile closure, typically cleaning up after prior logic.

" ....................{ LOCAL                             }....................
" If the current user has a custom Vim dotfile, source this file *AFTER*
" performing all other startup logic excluding that performed by this script.
if filereadable(g:our_vimrc_local_file)
    execute 'source ' . fnameescape(g:our_vimrc_local_file)
endif

" ....................{ GLOBALS                           }....................
" Notify vimrc-specific functions defined elsewhere (e.g., PrintError()) that
" Vim has successfully started up *AFTER* performing all other startup logic.
let g:our_is_startup = 0
