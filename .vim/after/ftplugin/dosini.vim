" --------------------( LICENSE                            )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Dosini-specific settings applied to all INI files of filetype ".ini".

" ....................{ PREAMBLE                           }....................
" If this plugin has already been loaded for the current buffer, return.
if exists("b:is_our_ftplugin_dosini")
    finish
endif

" ....................{ COMMENTS                           }....................
" Overwrite this mode's default comment leader with that set by "30-usage.vim".
setlocal comments=:#,fb:-

" ....................{ POSTAMBLE                          }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_dosini = 1
