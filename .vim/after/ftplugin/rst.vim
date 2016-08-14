" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" reStructuredText-specific settings applied to all files of filetype ".rst".

" ....................{ PREAMBLE                           }....................
" If this plugin has already been loaded for the current buffer, return.
if exists("b:is_our_ftplugin")
    finish
endif

" ....................{ BINDINGS                           }....................
" If the optional "InstantRst" bundle enabling reStructuredText buffer previews
" is available, bind:
"
" * <,Ps> to start previewing the current reStructuredText buffer.
" * <,PS> to start previewing all reStructuredText buffers.
" * <,Po> to stop previewing the current reStructuredText buffer.
" * <,PO> to stop previewing all reStructuredText buffers.
if neobundle#is_sourced('InstantRst')
    map <leader>Ps :InstantRst<cr>
    map <leader>PS :InstantRst!<cr>
    map <leader>Po :StopInstantRst<cr>
    map <leader>PO :StopInstantRst!<cr>
endif

" ....................{ POSTAMBLE                          }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin = 1
