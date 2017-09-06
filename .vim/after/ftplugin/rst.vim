" --------------------( LICENSE                            )--------------------
" Copyright 2015-2017 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" reStructuredText-specific settings applied to all files of filetype ".rst".

" ....................{ PREAMBLE                           }....................
" If this plugin has already been loaded for the current buffer, return.
if exists("b:is_our_ftplugin_rst")
    finish
endif

" ....................{ BINDINGS                           }....................
" If the optional "InstantRst" bundle enabling reStructuredText buffer previews
" is available, bind:
"
" * <-p> and <-ps> to start previewing the current reStructuredText buffer.
" * <-pS> to start previewing all reStructuredText buffers.
" * <-po> to stop previewing the current reStructuredText buffer.
" * <-pO> to stop previewing all reStructuredText buffers.
if neobundle#is_sourced('InstantRst')
    nnoremap <buffer> <localleader>p :InstantRst<cr>
    nnoremap <buffer> <localleader>ps :InstantRst<cr>
    nnoremap <buffer> <localleader>pS :InstantRst!<cr>
    nnoremap <buffer> <localleader>po :StopInstantRst<cr>
    nnoremap <buffer> <localleader>pO :StopInstantRst!<cr>
endif

" ....................{ POSTAMBLE                          }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_rst = 1
