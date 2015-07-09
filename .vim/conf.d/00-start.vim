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
    echomsg 'Vim version older than 7.4 detected. Expect horror.'
endif

" If "git" is not in the current ${PATH}, print a non-fatal warning. Subsequent
" logic (e.g., NeoBundle installation) requires Git as a hard dependency.
if !executable('git')
    echomsg 'Git not found. Expect death.'
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

" Create the passed directory and all parent directories of such directory as
" needed. This function provides a pure-Vim analogue to the external shell
" command "mkdir -p".
function MakeDirIfNotFound(path) abort
    if !isdirectory(a:path)
        call mkdir(a:path, 'p')
    endif
endfunction

" ....................{ HELPERS ~ testers                  }....................
" Return 1 if the current user is the superuser (i.e., "root") and 0 otherwise.
function IsSuperuser() abort
    return $USER == 'root'
endfunction

" Return 1 if Vim is running under a display server supporting the X11 protocol
" (e.g., X.org, XWayland, XMir, Cygwin/X) and 0 otherwise.
function IsDisplayServerX11() abort
    return $DISPLAY != ''
endfunction

" ....................{ CHECKS ~ features                  }....................
" If the current version of Vim was *NOT* compiled with the following optional
" features, print non-fatal warnings:
"
" * "+autocmd", required by everything everywhere. (Why is this even optional?)
" * "+signs", required by the "vim-gitgutter" bundle.
if !has('autocmd')
    echomsg 'Vim feature "autocmd" unavailable. Expect terror.'
endif
if !has('signs')
    echomsg 'Vim feature "signs" unavailable. Expect ugliness.'
endif

" If Vim is running under a display server supporting the X11 protocol but *NOT*
" compiled with the "+clipboard" or "+xterm_clipboard" features, print non-fatal
" warnings. For sane X11 usage, both should ideally be available. This can
" typically be rectified as follows:
"
" * Under Gentoo, reinstall "vim" with USE flag "X" enabled.
" * Under Ubuntu, uninstall the "vim" package and install the "vim-gtk" package.
if IsDisplayServerX11() && (!has('clipboard') || !has('xterm_clipboard'))
    echomsg 'Vim features "clipboard" or "xterm_clipboard" unavailable, but running under X11. Expect woe.'
endif

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
    " default, only filetype ".markdown" is associated with such mode. Despite
    " the fact that plasticboy's Markdown plugin associates Markdown mode with
    " the "mkd" rather than "markdown" filetype, only setting the latter here
    " produces the expected results. (We have no idea why. And we do not care.)
    autocmd BufNewFile,BufRead *.md setlocal filetype=markdown

    " Associate filetype ".spec" with Python mode. Such files are generated by
    " PyInstaller as intermediate makefiles; while such files are *NOT* valid
    " Python, they are Pythonic enough to parse as such.
    autocmd BufNewFile,BufRead *.spec setlocal filetype=python

    " Associate all shell scripts in all ".oh-my-zsh" and "oh-my-zsh"
    " directories of the current user's home directory with zsh mode. By
    " definition, oh-my-zsh as *ALWAYS* user-local.
    autocmd BufNewFile,BufRead ~/{*/,}{.,}oh-my-zsh/{*/,}*.sh
      \ setlocal filetype=zsh

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
