" --------------------( LICENSE                            )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Plaintext file-specific settings.

"FIXME: Actually, "formatoptions+=2" is great! Can we reliably enable that
"for other modes as well, at least in comments?

" ....................{ PREAMBLE                           }....................
" If this plugin has already been loaded for the current buffer, return.
if exists("b:is_our_ftplugin_text")
    finish
endif

" ....................{ FORMAT                             }....................
" Enable the following auto-formatting options for plaintext files:
"
" * "2", indenting plaintext according to the indentation of the second
"   rather than first line of the current paragraph.
"
" Ideally, option "a" autoformatting paragraphs (i.e., contiguous substrings
" separated by blank lines) would be enabled. However, such autoformatting
" behaves overzealously for our tastes and is hence disabled.
"
" Disable the following auto-formatting options for plaintext files:
"
" * "c", autoformatting comments. By definition, plaintext files are *NOT*
"   commentable in a standardized manner.
setlocal formatoptions+=2 formatoptions-=c

" Restore our preferred line length. External sources beyond our control (e.g.,
" the default "/etc/vimrc" shipped with Babun) often maliciously override this
" option for this filetype and hence must themselves be overridden.
let &textwidth = g:our_textwidth

" ....................{ POSTAMBLE                          }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_text = 1
