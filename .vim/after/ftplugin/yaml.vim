" --------------------( LICENSE                            )--------------------
" Copyright 2015-2017 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" YAML-specific settings applied to all files of filetype ".yaml".

" ....................{ PREAMBLE                           }....................
" If this plugin has already been loaded for the current buffer, return.
if exists("b:is_our_ftplugin_yaml")
    finish
endif

" ....................{ WRAPPING                           }....................
" Preferred line length for data markup languages only (e.g., HTML, YAML, XML).
let &l:textwidth = g:our_textwidth_data_markup

" ....................{ POSTAMBLE                          }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_yaml = 1
