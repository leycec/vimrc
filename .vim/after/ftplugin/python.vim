" --------------------( LICENSE                            )--------------------
" Copyright 2015-2018 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Python-specific settings.

" ....................{ PREAMBLE                           }....................
" If this plugin has already been loaded for the current buffer, return.
if exists('b:is_our_ftplugin_python')
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
" bundle is in the current ${PATH}, print a warning. In this case, Python
" buffers will be syntax-highlighted but *NOT* checked.
if !executable('pyflakes') && !executable('flake8')
    echomsg 'Commands "pyflakes" and "flake8" not found. Expect Python syntax checking to fail.'
endif

" ....................{ COMMENTS                           }....................
" Overwrite this mode's default comment leader with that set by "30-usage.vim".
setlocal comments=:#,fb:-

"FIXME: Currently disabled in favour of the default "fromstart" highlighting.

" Python-specific syntax highlighting is particularly troublesome. While the
" default "autocmd BufEnter * :syntax sync fromstart" suffices for most
" filetypes, Python plugins routinely fail to highlight large files under this
" default. The solution, of course, is to highlight significantly less. A
" cursory inspection of existing large Python files suggests this compromise.
augroup our_python_syntax
    " Buffer-local autocommands require buffer-local autocommond deletion.
    " Hence, "autocmd!" does *NOT* suffice here. For further details, see:
    "     https://vi.stackexchange.com/a/13456/16249
    autocmd! BufEnter <buffer>

    " Reparse syntax from a reasonable number of prior lines in this buffer on
    " every buffer movement. This is more conservative than the default of
    " reparsing syntax from the beginning of this buffer on every buffer
    " movement -- which, in theory, *SHOULD* improve the probability of success
    " in resynchronizing syntax highlighting.
    "
    " By inspection, it has been verified that this does indeed improve success
    " in resynchronizing syntax highlighting. The culprit appears to some
    " as-yet-undiagnosed combination of Vim 8.0, ALE, and python-mode when
    " highlighting large buffers. Until resolved, *PLEASE PRESERVE THIS.*
    "
    " See also the autoloadable vimrc#synchronize_syntax_highlighting()
    " function.
    autocmd BufEnter <buffer> :syntax sync minlines=1024
    "autocmd BufEnter <buffer> :syntax sync fromstart
augroup END

" ....................{ WRAPPING                           }....................
" For readability, visually soft-wrap long lines exceeding the width of the
" current window. Since the "python-mode" bundle explicitly disables this, only
" explicitly enabling this after loading that bundle suffices to re-enable this.
"
" See the same subsection of "conf.d/20-theme.vim".
setlocal wrap

" ....................{ POSTAMBLE                          }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_python = 1
