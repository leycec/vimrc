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

" ....................{ PATHABLES                          }....................
"FIXME: This implementation assumes no dirname in ${PATH} to contain commas.
"Generalize to handle this (admittedly unlikely) edge case.

" Get the absolute path of the passed pathable (i.e., command in the current
" $PATH) if this pathable exists or the empty string otherwise. This function
" should typically be preceded by an "if executable(pathable)" check ensuring
" this pathable to exist.
function GetPathablePath(pathable) abort
    " Platform-specific character delimiting dirnames in the current $PATH.
    let l:path_delimiter = has("win32") ? ';' : ':'

    " Return the first absolute path whose basename is the passed pathable and
    " whose dirname is a dirname in the current $PATH. To do so portably without
    " requiring external shell commands (which, as example, are unlikely to
    " exist under vanilla non-Cygwin-enabled Windows):
    "
    " 1. The current $PATH is converted into a comma-delimited list, as required
    "    by the globpath() builtin.
    " 2. A new list of all directories containing such pathable is created.
    "    Since globpath() returns a newline-delimited list rather than list by
    "    default, the optional arguments "0" and "1" *MUST* be passed. Backwards
    "    compatibility, you die.
    " 3. The first item of this list is returned.
    return globpath(
      \ substitute($PATH, l:path_delimiter, ',', 'g'),
      \ a:pathable, 0, 1)[0]
endfunction

" ....................{ SHELL                              }....................
" !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
" WARNING: To prevent spurious errors under insane shells and shell
" configurations, the following logic *MUST* be performed as early in Vim
" startup as feasible. Failure to do so results in errors under these shells
" resembling:
"
"     $ vim
"     Error detected while processing /home/leycec/.vim/conf.d/00-start.vim:
"     line   61:
"     E484: Can't open file /tmp/vkhYc9Y/0
" !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

" If "bash" is in the current ${PATH}, forcefully set Vim's preferred shell to
" "bash" *BEFORE* running the first shell command below (e.g., system()). Both
" Vim startup and numerous bundles assume this shell to be sane (e.g., to print
" no output on non-interactive startup and to conform to POSIX shell standards),
" which may *NOT* necessarily be the case for non-standard shells.
if executable('bash')
    let &shell = GetPathablePath('bash')
endif

" ....................{ GLOBALS ~ platform                 }....................
" Machine-readable capitalized name of the current platform (operating system).
" To improve error message granularity, this is defined *BEFORE* validating the
" current version of Vim. This is guaranteed to be one of the following names:
"
" * "Darwin", for OS X.
" * "Linux", for Linux.
" * "Windows", for Microsoft Windows.
" * The output of "uname -s", for all other platforms.
"
" For efficient platform checking during Vim startup, such name is set here.
"
" Ideally, such name could be set merely by portably testing for the existence
" of appropriate Vim features. Unfortunately, these features do *NOT*
" necessarily correspond to reality. On OS X:
"
" * Under CLI Vim, "has('unix')" returns 1 while both "has('mac')" and
"   "has('macunix')" return 0.
" * Under MacVim (both CLI and GUI), all three return 1.
"
" The failure of OS X Vim derivatives to reliably report their features renders
" the three features above (i.e., "mac", "macunix", and "unix") useless for
" platform detection. Hence, we test only those Vim features reliably indicating
" the current platform before falling back to capturing the standard output of
" the external "uname" command.
"
" The current platform is Microsoft Windows if and only if either of the
" following conditions holds:
"
" * The "win32" feature is available, in which case this in a vanilla Windows
"   CLI environment (e.g., "cmd.exe", PowerShell). Note the "32" refers to the
"   "win32" API encompassing all Windows platforms rather than only 32-bit
"   Windows platforms.
" * The "win32unix" feature is available, in which case this in a non-vanilla
"   Cygwin-enabled Windows CLI environment (e.g., "mintty.exe").
if has("win32") || has("win32unix")
    let g:our_platform = 'Windows'
" Else, the current platform is Unix-like and hence has the "uname" command.
else
    " Strip the trailing newline from such name.
    let g:our_platform = substitute(system('uname -s'), '\n', '', '')
endif

" ....................{ CHECKS                             }....................
" If the current version of Vim is insufficient, print a non-fatal warning. This
" requirement is currently dictated by:
"
" * "vim-gitgutter", a bundle:
"   * Recommending Vim >= 7.4.427 to avoid random highlighting glitches.
"   * Requiring Vim >= 7.3.105 for realtime highlighting.
if v:version < 704
    echomsg 'Vim version older than 7.4 detected. Expect horror.'

    " If the current platform is OS X, suggest use of the CLI-specific "vim"
    " installed with the Homebrew-managed MacVim port. Since the ideal command
    " for doing so is somewhat non-trivial, this command is also printed.
    "
    " For other platforms, upgrading Vim is typically trivial and hence omitted.
    if g:our_platform == 'Darwin'
        " If Homebrew is unavailable, recommend its installation.
        if !executable('brew')
            echomsg 'Consider installing Homebrew to correct this.'
        endif

        " If MacVim is unavailable, recommend its installation.
        if !executable('mvim')
            echomsg 'Consider installing the Homebrew-managed MacVim port as follows:'
            echomsg '    brew install macvim --with-override-system-vim --with-python3'
        endif
    endif
endif

" ....................{ GLOBALS                            }....................
" 1 if Vim is running under a display server supporting the X11 protocol (e.g.,
" X.org, XWayland, XMir, Cygwin/X) and 0 otherwise.
let g:our_is_display_server_x11 = $DISPLAY != ''

" 1 if Vim was compiled with Python 3 support *AND* "python3" is in the current
" ${PATH} and 0 otherwise. In the former case, Python 3 is available and
" presumably preferred to Python 2.
let g:our_is_python3 = has('python3') && executable('python3')

" 1 if the current user is the superuser (i.e., "root") and 0 otherwise.
let g:our_is_superuser = $USER == 'root'

" ....................{ GLOBALS ~ paths                    }....................
" Absolute path of Vim's top-level dot directory.
let g:our_vim_dir = $HOME . '/.vim'

" Absolute path of the current user's custom Vim dotfile.
let g:our_vimrc_local_file = $HOME . '/.vimrc.local'

" ....................{ GLOBALS ~ paths : bundle           }....................
" Absolute path of the directory to install bundles to.
let g:our_bundle_dir = g:our_vim_dir . '/bundle'

" Absolute path of the directory to install NeoBundle to, allowing NeoBundle to
" manage itself as a bundle.
let g:our_neobundle_dir = g:our_bundle_dir . '/neobundle.vim'

" ....................{ GLOBALS ~ paths : cache            }....................
" Absolute path of the directory to cache temporary paths to.
let g:our_cache_dir = g:our_vim_dir . '/cache'

" Absolute path of the directory to backup previously edited files to.
let g:our_backup_dir = g:our_cache_dir . '/backup'

" Absolute path of the directory to backup currently edited files to.
let g:our_swap_dir = g:our_cache_dir . '/swap'

" Absolute path of the directory to cache undo trees to.
let g:our_undo_dir = g:our_cache_dir . '/undo'

" ....................{ GLOBALS ~ paths                    }....................
" 1 if the current platform is Apple OS X and 0 otherwise.
let g:our_is_platform_osx = g:our_platform == 'Darwin'

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
"FIXME: Functions are inefficient. Replace all such testers by corresponding
"boolean globals. See g:our_is_python3 as an example.

" ....................{ HELPERS ~ testers : platform       }....................
" Return 1 if the current platform is Linux and 0 otherwise.
function IfPlatformLinux() abort
    return g:our_platform == 'Linux'
endfunction

" Return 1 if the current platform is Microsoft Windows and 0 otherwise.
function IfPlatformWindows() abort
    return g:our_platform == 'Windows'
endfunction

" Return 1 if the current platform is vanilla non-Cygwin-enabled Microsoft
" Windows and 0 otherwise.
function IfPlatformWindowsVanilla() abort
    return has("win32")
endfunction

" Return 1 if the current platform is non-vanilla Cygwin-enabled Microsoft
" Windows and 0 otherwise.
function IfPlatformWindowsCygwin() abort
    return has("win32unix")
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

" If Vim is running under a non-OS X display server supporting the X11 protocol
" but *NOT* compiled with both the "+clipboard" and "+xterm_clipboard" features,
" print non-fatal warnings. For sane X11 usage, both should ideally be
" available. This can typically be rectified as follows:
"
" * Under Gentoo, reinstall "vim" with USE flag "X" enabled.
" * Under Ubuntu, uninstall the "vim" package and install the "vim-gtk" package.
if g:our_is_display_server_x11 && !has('clipboard')
    " If running under OS X, only the "+clipboard" feature is typically enabled.
    " The "+xterm_clipboard" feature is *NOT* required for clipboard use.
    if g:our_is_platform_osx
        echomsg 'Vim feature "clipboard" unavailable, but running under OS X. Expect clipboard'
        echomsg 'integration to fail.'
    " Else, the "+xterm_clipboard" feature is required for clipboard use.
    elseif !has('xterm_clipboard')
        echomsg 'Vim features "clipboard" and "xterm_clipboard" unavailable, but running under'
        echomsg 'X11. Expect clipboard integration to fail.'
    endif
endif

" ....................{ CHECKS ~ pathables                 }....................
" If "git" is not in the current ${PATH}, print a non-fatal warning. Subsequent
" logic (e.g., NeoBundle installation) requires Git as a hard dependency.
if !executable('git')
    echomsg 'Command "git" not found. Expect NeoBundle installation to fail.'
endif

" If the current operation system is vanilla Microsoft Windows *AND*
" "mingw32-make" is not in the current ${PATH}, print a non-fatal warning. The
" "vimproc" bundle runs this command to compile itself under this platform.
if IfPlatformWindowsVanilla() && !executable('mingw32-make')
    echomsg 'Command "mingw32-make" not found. Expect NeoBundle installation to fail.'
" Else if "make" is not in the current ${PATH}, print a non-fatal warning. While
" generally unlikely, "make" is *NOT* installed under non-vanilla Cygwin-enabled
" Microsoft Windows by default. The "vimproc" bundle runs this command to
" compile itself under all platforms that are *NOT* vanilla Microsoft Windows.
elseif !executable('make')
    echomsg 'Command "make" not found. Expect NeoBundle installation to fail.'
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

    " Associate filetype ".spec" with Python mode. Such files are generated by
    " PyInstaller as intermediate makefiles; while such files are *NOT* valid
    " Python, they are Pythonic enough to parse as such.
    autocmd BufNewFile,BufRead *.spec setlocal filetype=python

    " Associate all files in the "~/.gitignore.d" directory with conf mode. Such
    " files are vcsh-specific files in canonical ".gitignore" format, which Vim
    " also assigns the same mode by default.
    autocmd BufNewFile,BufRead ~/.gitignore.d/* setlocal filetype=conf

    " Default undetected filetypes to "text". To ensure this default is applied
    " only as a fallback in the event no plugin or subsequent autocommand
    " detects a filetype, do so only on buffer switches rather than buffer
    " creation. (In other words, avoid use of "BufNewFile" and "BufRead" here.)
    autocmd BufEnter *
      \ if &filetype ==# "" |
      \     setlocal filetype=text |
      \ endif
augroup END

" --------------------( WASTELANDS                         )--------------------
    " Associate filetype ".md" with Markdown mode (e.g., as used by Github). By
    " default, only filetype ".markdown" is associated with this mode. The
    " filetype specified here *MUST* correspond to the filetype specific to the
    " current markdown bundle (e.g., "mkd" for plasticboy's).
    " autocmd BufNewFile,BufRead *.md setlocal filetype=mkd

"  Despite
    " the fact that plasticboy's Markdown plugin associates Markdown mode with
    " the "mkd" rather than "markdown" filetype, only setting the latter here
    " produces the expected results. (We have no idea why. And we do not care.)
    " autocmd BufNewFile,BufRead *.md setlocal filetype=markdown

" Return 1 if the current platform is Apple OS X and 0 otherwise.
" function IfPlatformOSX() abort
"     return g:our_platform == 'Darwin'
" endfunction

" Return 1 if Vim is running under a display server supporting the X11 protocol
" (e.g., X.org, XWayland, XMir, Cygwin/X) and 0 otherwise.
" function IsDisplayServerX11() abort
"     return $DISPLAY != ''
" endfunction

" Return 1 if Vim was compiled with Python 3 support *AND* "python3" is in the
" current ${PATH}, in which case Python 3 is available and presumably preferred
" to Python 2.
" function IsPython3() abort
"     return has('python3') && executable('python3')
" endfunction
" python3 4
    " if has("win32")
    "     let l:path_delimiter = ';'
    " else
    "     let l:path_delimiter = ':'
    " endif
    " echo 'pathable: ' . a:pathable . ', ' . l:pithy
    " return l:pithy
    " Return the first item of such list.
    " return l:pathables[1]
