" --------------------( LICENSE                            )--------------------
" Copyright 2015-2018 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Cascading style sheets (CSS)-specific settings.

" ....................{ PREAMBLE                           }....................
" If this plugin has already been loaded for the current buffer, return.
if exists("b:is_our_ftplugin_css")
    finish
endif

" ....................{ HIGHLIGHTING                       }....................
" Improve highlighting of CSS keywords containing hyphens (e.g.,
" "vertical-align", "box-shadow"). The following fix comes courtesy the
" following plugin installation instructions:
"     https://github.com/hail2u/vim-css3-syntax#notes
setlocal iskeyword+=-

" ....................{ POSTAMBLE                          }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_css = 1
