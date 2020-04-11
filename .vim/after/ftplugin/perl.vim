" --------------------( LICENSE                           )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                          )--------------------
" Perl-specific settings.

" ....................{ PREAMBLE                          }....................
" If this plugin has already been loaded for the current buffer, return.
if exists('b:is_our_ftplugin_perl')
    finish
endif

" ....................{ CHECKS                            }....................
" If no Perl syntax checker implicitly supported by ALE bundle is in the
" current ${PATH}, print a warning. In this case, Perl buffers will be
" syntax-highlighted but *NOT* checked.
if !executable('perlcritic')
    echomsg 'Command "perlcritic" not found. Expect Perl syntax checking to fail.'
endif

" ....................{ POSTAMBLE                         }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_perl = 1
