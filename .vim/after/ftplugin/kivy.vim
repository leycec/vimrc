" --------------------( LICENSE                           )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                          )--------------------
" Kivy-specific settings.

" ....................{ PREAMBLE                          }....................
" If this plugin has already been loaded for the current buffer, return.
if exists('b:is_our_ftplugin_kivy')
    finish
endif

" ....................{ SYNTAX                            }....................
" Overwrite this mode's default comment leader with that set by "30-usage.vim".
setlocal comments=:#,fb:-

" Overwrite this mode's default comment leader with that set by "30-usage.vim",
" yet again. If this setting is left unset, then various third-party commenting
" plugins (e.g., "tcomment_vim", "vim-commentary") incorrectly default to using
" the list prefix "-" as the comment leader. So it goes, peeps.
setlocal commentstring=#\ %s

" ....................{ POSTAMBLE                         }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_kivy = 1
