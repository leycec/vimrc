" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Dotfile closure, typically cleaning up after prior logic.

" ....................{ NEOBUNDLE                          }....................
" When reloading Vim, reconfigure all bundles *AFTER* defining all bundle hooks.
if !has('vim_starting')
    call neobundle#call_hook('on_source')
endif

" ....................{ LOCAL                              }....................
" If the current user has a custom Vim dotfile, source such file *AFTER*
" performing all other logic and hence as our penultimate action.
if filereadable(g:our_vimrc_local_file)
    execute 'source ' . fnameescape(g:our_vimrc_local_file)
endif

" --------------------( WASTELANDS                         )--------------------
