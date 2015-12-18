" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Python-specific settings.

" ....................{ PREAMBLE                           }....................
" If such plugin has already been loaded for the current buffer, return.
if exists("b:is_our_ftplugin")
    finish
endif

" ....................{ CHECKS                             }....................
" If Vim was *NOT* compiled with Python 3 support...
if !has('python3')
    " If Vim was also *NOT* compiled with Python 2 support, print a warning.
    " Since enabling the "python3" feature disables the "python" feature, test
    " this only after ensuring the former is disabled.
    if !has('python')
        echomsg 'Vim features "python" and "python3" unavailable. Expect Python syntax checking to fail.'
    " Else, Vim was compiled with only Python 2 support. Print a warning.
    else
        echomsg 'Vim feature "python3" unavailable. Expect Python 3 syntax checking to fail.'
    endif
endif

" If no Python syntax checker supported out-of-the-box by the "vim-watchdogs"
" bundle is in the current ${PATH}, print a warning. In such case, Python
" buffers will be syntax-highlighted but *NOT* checked.
if !executable('pyflakes') && !executable('flake8')
    echomsg 'Commands "pyflakes" and "flake8" not found. Expect Python syntax checking to fail.'
endif

" ....................{ WRAPPING                           }....................
" For readability, visually soft-wrap long lines exceeding the width of the
" current window. Since the "python-mode" bundle explicitly disables this, only
" explicitly enabling this after loading that bundle suffices to re-enable this.
"
" See the same subsection of "conf.d/20-theme.vim".
setlocal wrap

" ....................{ POSTAMBLE                          }....................
" Declare such plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin = 1

" --------------------( WASTELANDS                         )--------------------
" ....................{ SYNTAX CHECK ~ watchdogs           }....................
" Configure the Python-specific "pyflakes" syntax checker.
" let g:quickrun_config['watchdogs_checker/pyflakes'] = {
"   \ 'command': 'pyflakes',
"   \ 'cmdopt': '',
"   \ 'exec': '%c %o %s:p',
"   \ 'quickfix/errorformat': '%f:%l:%m',
"   \ }

" Syntax check Python buffers with such checker.
" let g:quickrun_config['python/watchdogs_checker'] = {
"   \ 'type' : 'watchdogs_checker/pyflakes',
"   \ }
