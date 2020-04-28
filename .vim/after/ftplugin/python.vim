" --------------------( LICENSE                           )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                          )--------------------
" Python-specific settings.

" ....................{ PREAMBLE                          }....................
" If this plugin has already been loaded for the current buffer, return.
if exists('b:is_our_ftplugin_python')
    finish
endif

" ....................{ CHECKS                            }....................
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

" If no Python syntax checker implicitly supported by ALE bundle is in the
" current ${PATH}, print a warning. In this case, Python buffers will be
" syntax-highlighted but *NOT* checked.
if !executable('pyflakes') && !executable('flake8')
    echomsg 'Commands "pyflakes" and "flake8" not found. Expect Python syntax checking to fail.'
endif

" ....................{ COMMENTS                          }....................
"FIXME: Consider refactoring the following into the comparable
""~/.vim/after/syntax/python.vim" plugin *WITHOUT* leveraging autocommands. In
"theory, simply defining "syntax sync minlines=1024" in that file as is should
"suffice to enable this functionality.

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
    " autocmd BufEnter <buffer> :syntax sync minlines=99999
    " autocmd BufEnter <buffer> :syntax sync fromstart

    " Overwrite this mode's default comment leader with that set by
    " "30-usage.vim".
    "
    " Note that this is non-ideal. Ideally, this mode's default comment leader
    " would be trivially settable by replacing this non-trivial command with
    " the following trivial command at the top-level of this script, as with
    " every other filetype:
    "     setlocal comments=:#,fb:-
    "
    " Interestingly, that approach *DID* successfully work for several years
    " before silently failing sometime in mid-2019 for unknown reasons. Now,
    " only the following non-trivial command suffices. *sigh*
    autocmd BufEnter <buffer> setlocal comments=:#,fb:-
augroup END

" ....................{ WRAPPING                          }....................
" For readability, visually soft-wrap long lines exceeding the width of the
" current window. Since the "python-mode" bundle explicitly disables this, only
" explicitly enabling this after loading that bundle suffices to re-enable this.
"
" See the same subsection of "conf.d/20-theme.vim".
setlocal wrap

" ....................{ POSTAMBLE                         }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin_python = 1
