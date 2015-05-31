" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Dotfile bootstrapping, principally defining dotfile-specific global variables
" and functions accessed by other dotfiles.

" ....................{ PROMPT                             }....................
" Sanitize prompt (i.e., Vim's audible and/or visual response to various events)
" settings as our initial action. The default prompt settings are sufficiently
" insane to warrant their addressing *BEFORE* attempting anything further.

" Do *NOT* "ring the bell" (e.g., audible beep, screen flash) on errors.
set noerrorbells
set novisualbell

" Do *NOT* prompt users to press <Enter> on each screen of long listings.
set nomore

" ....................{ CHECKS                             }....................
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

" Absolute path of the current user's custom Vim dotfile.
let g:our_vimrc_local_file = $HOME . '/.vimrc.local'

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
" Helper functions guaranteed to be called at (and hence unconditionally
" required by) Vim startup. All other such functions are only conditionally
" required under certain contexts. For efficiency, such functions are autoloaded
" in a just-in-time (JIT) manner and hence reside under "~/.vim/autoload".

" Append the passed directory to Vim's ","-delimited PATH. For safety, all ","
" characters in such directory will be implicitly escaped.
function AddRuntimePath(path) abort
    let &runtimepath .= ',' . escape(a:path, '\,')
endfunction

" True if the current user is the superuser (i.e., "root").
function IsSuperuser() abort
    return $USER == 'root'
endfunction

" Create the passed directory and all parent directories of such directory as
" needed. This function provides a pure-Vim analogue to the external shell
" command "mkdir -p".
function MakeDirIfNotFound(path) abort
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
augroup our_filetype_detect
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
