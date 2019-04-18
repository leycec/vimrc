" --------------------( LICENSE                           )--------------------
" Copyright 2015-2018 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                          )--------------------
" reStructuredText-specific settings applied to all files of filetype ".rst".

" ....................{ PREAMBLE                          }....................
" If this plugin has already been loaded for the current buffer, return.
if exists('b:is_our_ftplugin_rst')
    finish
endif

" ....................{ BINDINGS                          }....................
" If the optional "InstantRst" plugin enabling reStructuredText buffer previews
" is available, bind:
"
" * <-p> and <-ps> to start previewing the current reStructuredText buffer.
" * <-pS> to start previewing all reStructuredText buffers.
" * <-po> to stop previewing the current reStructuredText buffer.
" * <-pO> to stop previewing all reStructuredText buffers.
if dein#tap('InstantRst')
    nnoremap <buffer> <localleader>p :InstantRst<cr>
    nnoremap <buffer> <localleader>ps :InstantRst<cr>
    nnoremap <buffer> <localleader>pS :InstantRst!<cr>
    nnoremap <buffer> <localleader>po :StopInstantRst<cr>
    nnoremap <buffer> <localleader>pO :StopInstantRst!<cr>
endif

" ....................{ COMMENTS                          }....................
" Parse all ".. #" substrings prefixing any line and suffixed by whitespace as
" comment leaders. Technically, reStructuredText has *NO* formal comment
" leaders. In practice, this comment leader conforms with modern expectations
" (mostly due to the terminating "#", inherited from numerous popular
" languages) and hence suffices as a suitable default.
"
" Dismantled, this is:
"
" * "b:", requiring this comment leader to be suffixed by whitespace. This is a
"   hard constraint imposed by reStructuredText syntax.
"
" For further details, see ":help format-comments".

"FIXME: Unfortunately, this does *NOT* behave as expected. It should. In all
"likelihood, either:
"
"* Vim silently fails for comment leaders containing whitespace.
"* Parsing performed by the reST plugin silently conflicts with this.
"
"We suspect the former, frankly.
let b:comments = 'b:.. #'

" ....................{ POSTAMBLE                         }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_rst = 1
