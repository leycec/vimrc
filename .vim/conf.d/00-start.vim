" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Dotfile bootstrapping, principally defining dotfile-specific global variables
" and functions accessed by other dotfiles.

" ....................{ SANITY                             }....................
" If the current version of Vim is insufficient, print a non-fatal warning. This
" requirement is currently dictated by:
"
" * "vim-gitgutter", a bundle:
"   * Recommending Vim >= 7.4.427 to avoid random highlighting glitches.
"   * Requiring Vim >= 7.3.105 for realtime highlighting.
if v:version < 704
    echoerr 'Vim version older than 7.4 detected. Consider upgrading to avoid spurious errors.'
endif

" If the current version of Vim was *NOT* compiled with the following optional
" features, print non-fatal warnings:
"
" * "signs", required by the "vim-gitgutter" bundle.
if !has('signs')
    echoerr 'Vim feature "signs" unavailable. Consider reinstalling Vim with this feature enabled to avoid spurious errors.'
endif

" If "git" is not in the current ${PATH}, print a non-fatal warning. Subsequent
" logic (e.g., NeoBundle installation) runs and hence requires Git.
if !executable('git')
    echoerr 'Git not found. Consider installing Git to avoid spurious errors.'
endif

" ....................{ PATHS                              }....................
" Absolute path of Vim's top-level dot directory.
let g:our_vim_dir = $HOME . '/.vim'

" ....................{ PATHS ~ bundle                     }....................
" Absolute path of the directory to install bundles to.
let g:our_bundle_dir = g:our_vim_dir . '/bundle'

" Absolute path of the directory to install NeoBundle to, allowing NeoBundle to
" manage itself as a bundle.
let g:our_neobundle_dir = g:our_bundle_dir . '/neobundle.vim'

" ....................{ PATHS ~ cache                      }....................
" Absolute path of the directory to cache temporary paths to.
let g:our_cache_dir = g:our_vim_dir . '/cache'

" Absolute path of the directory to backup previously edited files to.
let g:our_backup_dir = g:our_cache_dir . '/backup'

" Absolute path of the directory to backup currently edited files to.
let g:our_swap_dir = g:our_cache_dir . '/swap'

" Absolute path of the directory to cache undo trees to.
let g:our_undo_dir = g:our_cache_dir . '/undo'

" ....................{ HELPERS                            }....................
" True if the current user is the superuser (i.e., "root").
function IsSuperuser()
    return $USER == 'root'
endfunction

" Append the passed directory to Vim's ","-delimited PATH. For safety, all ","
" characters in such directory will be implicitly escaped.
function AddRuntimePath(path)
    let &runtimepath .= ',' . escape(a:path, '\,')
endfunction

" Get the script ID (SID) that Vim assigned to the script with the passed
" absolute path. This function is principally intended to break the thin veneer
" of privacy provided by "s:", syntactic sugar prefixing function names which
" Vim internally mangles into "<SNR>${SID}_" (where "${SID}" is the SID of the
" script declaring such functions). This function is a shameless mashup of the
" following two external functions, for which we are effervescently grateful:
"
" * Yasuhiro Matsumoto's GetScriptID() function, published at:
"   http://mattn.kaoriya.net/software/vim/20090826003359.htm
" * Yasuhiro Matsumoto's GetScriptID() function, published at:
"   http://mattn.kaoriya.net/software/vim/20090826003359.htm
function! GetScriptSID(script_filename)
    " Capture the contents of the buffer output by calling scriptnames() to a
    " function-local variable.
    redir => l:scriptnames_output
    silent! scriptnames
    redir END

    " If the passed filename is prefixed by the absolute path of the current
    " user's home directory, replace such prefix by "~". This permits such path
    " to be matched in such output, which does the same.
    let l:script_filename = substitute(
      \ a:script_filename, '^' . $HOME . '/', '~/', '')

    " Parse such output as follows:
    "
    " * Split such output on newlines. Vim guarantees each resulting line to be
    "   formatted as "${SID}: ${script_filename}", where:
    "   * The first listed script has SID 1.
    "   * Each successive script an SID one larger than the prior.
    " * Reduce each such line to its filename. SIDs are guaranteed to follow a
    "   simple pattern and hence ignorable for our purposes.
    " * Get one less than the line number of the script with the passed
    "   filename or -1 if such script has *NOT* been sourced yet.
    let l:script_line = index(
      \ map(
      \   split(l:scriptnames_output, "\n"),
      \   "substitute(v:val, '^[^:]*:\\s*\\(.*\\)$', '\\1', '')"
      \ ), l:script_filename)

    " If such script has *NOT* been sourced yet, print a non-fatal warning.
    if l:script_line == -1
        throw '"' . l:script_filename . '" not previously sourced.'
    endif

    " Return the line number of such script -- which, by Vim design, is
    " guaranteed to be such script's SID.
    return l:script_line + 1
endfunction

" Get the function with the passed name declared by the script with the passed
" absolute path. This function is principally intended to break the thin veneer
" of privacy provided by "s:". See GetScriptSID() for details. This function is
" appropriated wholesale from the following external function, for which we are
" (again) indelicately grateful:
"
" * Kanno Kanno's s:get_func() function, published at:
"   http://kannokanno.hatenablog.com/entry/20120720/1342733323
function! GetScriptFunction(script_filename, function_name)
    let l:sid = GetScriptSID(a:script_filename)
    return function("<SNR>" . l:sid . '_' . a:function_name)
endfunction

" Create the passed directory and all parent directories of such directory as
" needed, providing a Vim analogue of "mkdir -p".
function MakeDirIfNotFound(path)
    if !isdirectory(a:path)
        call mkdir(a:path, 'p')
    endif
endfunction

" ....................{ PATHS ~ make                       }....................
" Create all requisite subdirectories as needed.
call MakeDirIfNotFound(g:our_backup_dir)
call MakeDirIfNotFound(g:our_bundle_dir)
call MakeDirIfNotFound(g:our_swap_dir)
call MakeDirIfNotFound(g:our_undo_dir)

" ....................{ FILETYPE                           }....................
" Associate Vim-specific filetypes with filename-embedded filetypes *BEFORE*
" subsequent logic, much of which depends on Vim-specific filetypes.
augroup filetype_detect
    autocmd!

    " Associate filetype ".md" with Markdown mode (e.g., as used by Github). By
    " default, only filetype ".markdown" is associated with such mode.
    autocmd BufNewFile,BufRead *.md setlocal filetype=markdown

    " Associate filetype ".spec" with Python mode. Such files are generated by
    " PyInstaller as intermediate makefiles; while such files are *NOT* valid
    " Python, they are Pythonic enough to parse as such.
    autocmd BufNewFile,BufRead *.spec setlocal filetype=python

    " Associate all files in the "~/.gitignore.d" directory with conf mode. Such
    " files are vcsh-specific files in canonical ".gitignore" format, which Vim
    " also assigns the same mode by default.
    autocmd BufNewFile,BufRead ~/.gitignore.d/* setlocal filetype=conf

    " Default undetected filetypes to "text". To ensure such default is applied
    " only as a fallback in the event no plugin or subsequent autocommand
    " detects such filetype, do so only on buffer switches rather than buffer
    " creation. (In other words, avoid use of "BufNewFile" and "BufRead" here.)
    autocmd BufEnter *
      \ if &filetype ==# "" |
      \     setlocal filetype=text |
      \ endif
augroup END

" --------------------( WASTELANDS                         )--------------------
    " set shell=/bin/bash
    " execute '!git clone https://github.com/Shougo/neobundle.vim /home/leycec/.vim/bundle/neobundle.vim'
    " silent system(
    "   \ 'git clone https://github.com/Shougo/neobundle.vim ' .
    "   \ shellescape(g:our_neobundle_dir)
    "   \ )
    " silent !git clone https://github.com/Shougo/neobundle.vim g:our_neobundle_dir
" call neobundle#begin(expand('~/.vim/bundle/'))
    " set runtimepath+=~/.vim/bundle/neobundle.vim/
    " Inform the user of imminent strangeness.
    " Install NeoBundle to such directory.
    " Make the parent directory of the directory to install NeoBundle to.
" Helper functions called below.
    " echo ''
