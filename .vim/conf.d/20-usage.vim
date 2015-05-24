" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.

"FIXME: "python-mode" provides Rope support, which we should both learn and
"configure appropriately. Rope is basically PyCharm for Vim, providing deep
"introspection, analysis, and refactoring of Python on a project-wide basis from
"within Vim -- without use of external tag files. Yeah; it's friggin' sweet.
"See: https://github.com/klen/python-mode

" ....................{ BINDINGS                           }....................
" Bind <;> to <:> and <:> to <;> in normal and visual modes. This reduces the
" number of keystrokes required to enter Ex commands -- which, ammortized over
" time, can dramatically reduce keystroke load.
" nnoremap ; :
" nnoremap : ;
" xnoremap ; :
" xnoremap : ;

" Bind <j> and <k> to move up and down by logical rather than physical lines.
" In particular, this allows line-wrapped lines to be navigated naturally.
nnoremap j gj
nnoremap k gk

" ....................{ BINDINGS ~ ex                      }....................
" Bind <:w!!> to reopen the current file for writing with superuser privelages.
cnoremap <silent> w!! w !sudo tee % >/dev/null

" ....................{ BINDINGS ~ leader                  }....................
" Bind <> to "<Leader>", a symbolic user-specific prefix for Vim key bindings.
" By design, such prefix is guaranteed to *NOT* conflict with default bindings,
" and hence provides a safe namespace with which to define custom key bindings.
let mapleader=","

"FIXME: This probably isn't quite right.
" Bind <,e> to open a new buffer editing a file discovered via Unite.
nnoremap <leader>e :Unite<cr>

" Bind <,w> to write the current buffer. This avoids the need to otherwise
" confirm such write with a prefixing <Enter>, reducing keystroke load.
nnoremap <leader>w :w<cr>

" Bind <,u> to toggle the undo-tree panel. (Vim 7.0 generalized the undo history
" from a uniform path to branching tree.)
nnoremap <leader>u :UndotreeToggle<cr>

" Bind <,vr> to reload Vim's startup scripts (e.g., this file).
nnoremap <silent> <leader>vr load-vim-script $MYVIMRC<cr>

" Bind <,/> to dehighlight all terms found by the prior search. This preserves
" the search history and hence is preferable to manually searching for garbage
" strings (e.g., "/ oeuoeuoeu").
nnoremap <silent> <leader>/ :nohlsearch<cr>

" ....................{ BINDINGS ~ leader : fugitive       }....................
" Bind <,Gu> to open a new buffer diffing the working tree against the index.
nnoremap <leader>Gu :GreviewUnstaged<cr>

" Bind <,Gs> to open a new buffer diffing the index against the current HEAD.
nnoremap <leader>Gs :GreviewStaged<cr>

" Bind <,Ge> to open a new buffer viewing and editing the index.
nnoremap <leader>Ge :Gstatus<cr>

" ....................{ HELPERS                            }....................
" Helper functions called below.

" True if the current user is the superuser (i.e., "root").
function IsSuperuser()
    return $USER == 'root'
endfunction

" Create the passed directory and all parent directories of such directory as
" needed, providing a Vim analogue of "mkdir -p".
function MakeDirIfNotFound(path)
    if !isdirectory(a:path)
        call mkdir(a:path, "p")
    endif
endfunction

" ....................{ BUFFERS                            }....................
" Common buffer commands include:
"     :b{number}        " switch to the buffer with that number
"     :ls               " list all buffers

" Permit unsaved buffers to be hidden (i.e., switched from) on opening a new
" buffer in the current window. By default, Vim requires unsaved buffers to be
" either saved or discarded before opening a new buffer.
set hidden

" On opening a new buffer, set such buffer's encoding to the first of the
" following encodings to successfully decode such buffer's content. This 
" includes the following Japanese-specific encodings:
"
" * "iso-2022-jp", commonly referred to as JIS.
" * "cp932", commonly referred to as SHIFT-JIS.
" * "euc-jp".
"
" This list comes courtesy Francisco at:
" http://dallarosa.tumblr.com/post/13278782524/a-tale-of-japanese-support-on-vim
set fileencodings=utf8,iso-2022-jp,euc-jp,cp932,default,latin1
" set fileencodings=iso-2022-jp,euc-jp,cp932,utf8,default,latin1

" ....................{ CACHING                            }....................
" Absolute path of the directory to cache files to.
let g:my_cache_dir = $HOME . '/.vim/cache/'

" Create cache subdirectories if needed.
call MakeDirIfNotFound(g:my_cache_dir . 'backup')
call MakeDirIfNotFound(g:my_cache_dir . 'swap')
call MakeDirIfNotFound(g:my_cache_dir . 'undo')

" ","-delimited list of settings configuring persistence for the current editing
" session. Dismantled, this is:
"
" * "%", saving all buffers and restoring such buffers when Vim is run without
"   file arguments.
" * "<", saving and restoring at most the passed number of lines for registers.
" * "/", saving and restoring at most the passed number of search patterns.
" * "'", saving and restoring marks for at most the passed number of files.
" * "h", preventing search matches highlighted under the prior session from
"   being highlighted on restoring such session.
" * "s", *NOT* saving or restoring items (currently, only registers) larger than
"   the passed number of kilobytes.
" * "n", persisting all such metadata to and from the passed filename.
let &viminfo = '%,<1024,/64,''64,h,n' . g:my_cache_dir . ' viminfo,s8'

" ....................{ CACHING ~ backup                   }....................
" Directory persisting backups of edited files to corresponding files.
"
" To ensure the uniqueness of such files in such directory, suffix such
" directory with "//", in which case the basenames of backup files will be the
" absolute paths of the original files with all directory separators "/"
" replaced by "%".
let &backupdir = g:my_cache_dir . 'backup//'
set backup

" ....................{ CACHING ~ swap                     }....................
" Directory persisting swap files (i.e., recoverable backups) of edited files to
" corresponding files. See above for further details on "//".
let &directory = g:my_cache_dir . 'swap//'

" ....................{ CACHING ~ undo                     }....................
" See section "HISTORY" for related settings.

" If Vim supports undo persistence...
if has("persistent_undo")
    " Directory persisting the undo history trees of edited files to
    " corresponding files. See above for further details on "//".
    let &undodir = g:my_cache_dir . 'undo//'
    set undofile
endif

" ....................{ CLIPBOARD                          }....................
" Alias the anonymous register (i.e., the default register for yanks, puts, and
" cuts) to the "+" register (i.e., X11's system clipboard) such that copying to
" and pasting from the clipboard is as simple as copying and pasting text
" without a destination register.
set clipboard=unnamedplus

" ....................{ COMMENTING ~ tcomment              }....................
" tcomment.

" ....................{ DELETING                           }....................
"FIXME: Specifically? What does this do? I like it, but I'd like to know more.

" Sanitize <Backspace>.
set backspace=indent,eol,start

" ....................{ DIFFING                            }....................
" Enable the following diffing options by default:
"
" * "filler", display filler lines (i.e., contextual lines whose sole purpose is
"   to synchronize vertically-split diff buffers).
" * "vertical", opening "diff" mode with vertical rather than horizontal splits.
set diffopt=filler,vertical

" ....................{ EXPLORING ~ unite                  }....................
" Since unite is loaded lazily, defer its configuration until loaded.
let s:hooks = neobundle#get_hooks('unite.vim')
function! s:hooks.on_source(bundle)
    " Match "fuzzily," effectively inserting the nongreedy globbing operator
    " "*?" between each character of the search pattern (e.g., searching for
    " "vvrc" in a unite buffer matches both "~/.vim/vimrc" and
    " "~/.vim/bundle/vundle/startup/rc.vim").
    call unite#filters#matcher_default#use(['matcher_fuzzy'])

    " Sort unite matches by descending rank.
    call unite#filters#sorter_default#use(['sorter_rank'])

    " Directory to which unite caches metadata.
    let g:unite_data_directory = g:my_cache_dir . 'unite'

    " Open unite buffers in Insert Mode by default.
    let g:unite_enable_start_insert = 1

    " String prefixing the unite input prompt.
    let g:unite_prompt = '» '

    " Enable unite source "unite-source-history/yank", permitting exploration of the
    " yank history (e.g., as via plugins "yankring" and "yankstack").
    let g:unite_source_history_yank_enable = 1
endfunction

" ....................{ EXPLORING ~ files                  }....................
" Common file exploration commands include:
"     :VimFiler         " run vimfiler

" Since vimfiler is loaded lazily, defer its configuration until loaded.
let s:hooks = neobundle#get_hooks('vimfiler')
function! s:hooks.on_source(bundle)
    " Set vimfiler as the default file explorer.
    let g:vimfiler_as_default_explorer = 1
endfunction

" ....................{ FILETYPE ~ markdown : tpope        }....................
" Tim Pope's Markdown plugin.

" List of all "fenced languages" in Github-flavored Markdown code blocks. The
" opening delimiter "```" of such blocks may be suffixed by a string signifying
" the language the following block should be syntax highlighted as, in which
" case this plugin recognizes and syntax highlights such blocks accordingly.
"
" If the Github- and hence Linguist-specific language name differs from the
" corresponding Vim filetype, the former must be explicitly mapped to the latter
" with an "="-delimited item; else, simply listing such name suffices.
"
" For the full list of Github-specific language names, see:
" https://github.com/github/linguist/blob/master/lib/linguist/languages.yml
let g:markdown_fenced_languages = [
  \ 'css',
  \ 'javascript', 'js=javascript',
  \ 'json=javascript',
  \ 'ruby',
  \ 'xml',
  \ 'zsh',
  \ ]

" ....................{ FILETYPE ~ python-mode             }....................
" Enable Python 3- rather than 2-specific functionality. (Currently, the latter
" is the default.)
let g:pymode_python = 'python3'

" Disable all folding functionality in "python-mode".
let g:pymode_folding = 0

" Prevent "python-mode" from performing syntax checks (e.g., on buffer write),
" as "watchdogs" already does so in a (frankly) superior manner.
let g:pymode_lint = 0

" If the current user is the superuser, prevent Rope from recursively searching
" for ".ropeproject" directories in parent directories of the current directory
" if the latter contains no ".ropeproject" directory. Since the superuser
" typically edits top-level files containing no such directory, such
" functionality customarily causes Rope to recursively search the entire disk
" and hence hang Vim. (This is bad.)
if IsSuperuser()
    let g:pymode_rope_lookup_project = 0
" Else, permit Rope to perform such recursive searches.
else
    let g:pymode_rope_lookup_project = 1
endif

" Disable Rope-based autocompletion on typing <.> in Insert mode. As of this
" writing, such behaviour appears to either be broken or conflict with another
" plugin also hooking Insert mode events (e.g., "watchdogs").
let g:pymode_rope_complete_on_dot = 0

" ....................{ FILETYPE ~ syntax                  }....................
" Enable Python-specific syntax highlighting.
let g:pymode_syntax = 1

" Highlight all possible syntax.
let g:pymode_syntax_all = 1

" Highlight print() according to Python 3 rather than 2 semantics.
let g:pymode_syntax_print_as_function = 1

" Highlight in the most reliable, albeit least efficient, manner. This improves
" but does *NOT* perfect syntax highlighting of Python code containing long
" strings. In particular, single-quoted strings formatted as parens-delimited
" single-quoted lines will typically *NOT* be highlighted properly, suggesting
" such strings be reformatted as triple-quoted strings with dedendation: e.g.,
"
"     # This will probably fail to be properly highlighted.
"     my_bad_string = (
"         'First line.\n'
"         'Second line.\n'
"         ...
"         'Ninety-ninth line.\n'
"         'Hundredth line.'
"     )
"
"     # This, however, will not.
"     my_good_string =\
"         '''First line.
"         Second line.
"         ...
"         Ninety-ninth line.
"         Hundredth line.'''
let g:pymode_syntax_slow_sync = 1

" ....................{ FOLDING                            }....................
" Disable folding globally. However, intentionally or accidentally performing a
" folding action (e.g., by typing <zc>) implicitly undoes this by re-enabling
" folding globally. Hence, this alone is *NOT* sufficient to disable folding.
set nofoldenable

" Disable folding, part deux. This ensures that even in the event of Vim re-
" enabling folding on a particular buffer, folding will appear to remain
" disabled. (Arguably the worst "feature" that Vim foists on hapless users.)
set foldlevelstart=99
set foldlevel=99

" ....................{ FORMAT ~ filetype                  }....................
" Filetype-specific formatting. For safety, append and shift list
" "formatoptions" with the "+=" and "-=" operators rather than overwriting such
" list (and hence sane Vim defaults) with the "=" operator. See ":h fo-table".
"
" For efficiency, formatting specific to single filetypes is isolated into the
" "after/ftplugin" directory.
augroup filetype_format
    autocmd!

    " Enable option "t" autowrapping for markup-specific filetypes (e.g., XML)
    " for which newlines are largely insignificant and hence automatically
    " insertable without issue.
    autocmd FileType yaml setlocal formatoptions+=t

    " Enable comment-aware text formatting for *ALL* code-specific filetypes
    " (i.e., filetypes supporting comments), regardless of whether the plugins
    " configuring such filetypes already do so. The following code-specific
    " filetypes are omitted:
    "
    " * "zeshy", as the zeshy plugin already enables such formatting.
    "
    " Dismantled, this is:
    "
    " * "c", autowrapping comments.
    " * "r", autoinserting comment leaders on <Enter> in Insert mode.
    " * "o", autoinserting comment leaders on <o> and <O> in Normal mode.
    " * "q", autoformatting comments on <gq> in Normal mode.
    " * "n", autoformatting commented numbered lists sanely.
    " * "j", removing comment leaders when joining lines.
    " * "m", breaking long lines at multibyte characters (e.g., for Asian languages
    "   in which characters signify words).
    " * "B", *NOT* inserting whitespace between adjacent multibyte characters when
    "   joining lines.
    autocmd FileType
      \ ebuild,markdown,python,sh,vim,yaml,zsh
      \ setlocal formatoptions+=croqnjmB
augroup END

" ....................{ GLOBBING                           }....................
" When globbing, ignore files matching the following glob patterns.
set wildignore=*.class,*.dll,*.exe,*.gif,*.jpg,*.o,*.obj,*.png,*.py[co],*.so,*.swp

" ....................{ HISTORY                            }....................
" See section "TEMPORARY PATHS" for related settings.

" Maximum number of per-session ex commands and search patterns to be persisted.
set history=1000

" Maximum number of per-buffer undos to be persisted.
set undolevels=1000

" ....................{ INDENTATION                        }....................
" Common indentation commands include:
"     :retab            " convert all tabs in the current buffer to spaces
"     :set paste        " disable auto-identation when pasting text

" Automatically indent new lines according to indentation of existing lines.
set autoindent
set copyindent

" By default, indent the following lexical constructs:
"
" * "+", continuation lines (e.g., "\"-suffixed lines under most languages).
"
" Each such construct expects a mandatory integer argument suffixed by an
" optional character, formatted as follows:
"
" * If such argument is suffixed by "s", such integer signifies a multiple of
"   the current buffer's "shiftwidth".
" * Else, such integer signifies a number of literal spaces.
"set cinoptions+=+0.5s

" ....................{ INDENTATION ~ filetype             }....................
" Filetype-specific indentation.
augroup filetype_indentation
    autocmd!

    " By default (in order):
    "
    " * Bind <Tab> to insert this many spaces.
    " * Bind "<<" and ">>" to shift by this many spaces.
    " * Set the width of tab characters (i.e., '\t') to this many spaces.
    " * Bind <Tab> to insert spaces rather than tabs.
    "
    " Ensure this overwrites plugin defaults by setting such options *AFTER*
    " opening new buffers and hence running such plugins.
    autocmd FileType * setlocal softtabstop=4 shiftwidth=4 tabstop=4 expandtab

    " For markup-specific filetypes (e.g., XML), reduce the default tab width.
    " Since markup tends to heavily nest, this helps prevent overly long lines
    " and hence improve readability.
    autocmd FileType html,yaml setlocal softtabstop=2 shiftwidth=2 tabstop=2

    " For filetypes in which tabs are significant (e.g., ebuilds, makefiles),
    " bind <Tab> to insert tabs rather than spaces.
    autocmd FileType ebuild,make setlocal noexpandtab
augroup END

" ....................{ INDENTATION ~ vim                  }....................
" Indent "\"-prefixed continuation lines by half of the shiftwidth.
let g:vim_indent_cont = 2

" ....................{ MACROS                             }....................
" When executing macros, redraw the screen only after such macros complete.
set lazyredraw

" ....................{ MODES                              }....................
" Check the first 8 lines of new buffers for Vim modelines. By default, Gentoo
" and other distributions disable such checking. Typically, modelines resemble:
"
"     # Declare this file to be of Vim type "conf", regardless of filename.
"     # vim: set filetype=conf:
set modeline
set modelines=8

" ....................{ MOUSE                              }....................
" Enable terminal mouse support.
set mouse=a

" ....................{ NAVIGATING                         }....................
" Constrain the cursor to actual characters for all modes *EXCEPT* (i.e., enable
" virtual editing for) the following:
"
" * "block", Visual block mode.
" * "insert", Insert mode.
" * "all", all modes.
" * "onemore", permit the cursor to only move past the end of the line.
set virtualedit=block

" ....................{ REFORMATTING ~ vim-autoformat      }....................
" Permit the Python-specific "autopep8" reformatter to aggressively reformat
" long lines. While "vim-autoformat" provides default options for such
" reformatter under "plugin/defaults.vim", "autopep8" senselessly ignores option
" "--max-line-length" unless at least *TWO* aggressive options are also passed.
let g:formatprg_python = "autopep8"
let g:formatprg_args_expr_python = '"- --experimental --aggressive --aggressive --aggressive ".(&textwidth ? "--max-line-length=".&textwidth : "")'

" ....................{ REMOTING                           }....................
" Prevent the default "netrw" plugin from littering working trees with
" ".netrwhist" files caching history and bookmarks for remotely edited files.
" While it would probably be better to reconfigure "netrw" to add such files to
" the "~/.vim/cache" subdirectory, it's unclear how to effect that; so, we
" currently disable them entirely.
let g:netrw_dirhistmax = 0

" ....................{ SEARCHING                          }....................
" Highlight all matching substrings in the current buffer.
set hlsearch

" Search incrementally (i.e., as you type).
set incsearch

" Search for all-lowercase regexes case-insensitively and all other regexes
" (i.e., regexes containing at least one uppercase character) case-sensitively.
"
" Do *NOT* globally enable "ignorecase", as doing so unhelpfully applies to
" substitutions, which should generally be searched for case-sensitively.
" Instead, selectively enable such option only for searching with "\c" above.
set smartcase

" ....................{ SEARCHING ~ magic                  }....................
" Enable the following per-regex options globally:
"
" * "\v" when both searching and substituting, enabling "very magic" regex
"   syntax (i.e., resembling PCREs, such that regex-reserved characters need
"   *NOT* be explicitly prefixed by "\"). Technically, Vim provides no means of
"   globally doing so, instead requiring such syntax be locally enabled on a
"   per-regex basis by prefixing such regexes with "\v". Since genuinely
"   enabling such syntax globally would break third-party scripts expecting
"   default "magic" syntax, this constraint is understandable (if onerous). To
"   circumvent this safely, remap search key prefixes to prefix all
"   interactively entered regexes with "\v."
nnoremap / /\v
nnoremap ? ?\v

" While the above succinctly suffices for simple searches, such approach does
" *NOT* extend to substitutions or other complex search operations. Instead,
" instruct the "EnchantedVim" plugin to do so on our behalf. Since such
" plugin's simple search support conflicts with option "incsearch" *AND* since
" the above already suffices for such support, disable such plugin's simple
" search support (enabled by default) and enable such plugin's more complex
" search support (disabled by default). (You know how it is.)
let g:VeryMagic = 0
let g:VeryMagicFunction = 1
let g:VeryMagicHelpgrep = 1
let g:VeryMagicRange = 1
let g:VeryMagicSubstitute = 1
let g:VeryMagicVimGrep = 1

" ....................{ SEARCHING ~ replace                }....................
" Enable global substitutions by default (i.e., implicitly append "/g" to all
" substitutions). Appending "/g" to a substitution now disables global
" substitution, as expected.
set gdefault

" ....................{ SHELL COMMANDS                     }....................
" Absolute path of the default shell with which to run commands.
set shell=/bin/zsh

" ....................{ SPELLING                           }....................
"FIXME: This works, but it looks hideous on the console. Ideally, it would
"only apply to commented blocks and even then only lightly highlight or
"underline the mispelled words. Until reconfiguring this for aesthetic sanity,
"this is disabled.
" Enable English spell checking.
"setlocal spell spelllang=en

" ....................{ SYNTAX CHECK ~ watchdogs : start   }....................
" "vim-watchdogs" provides asynchronous syntax checking.

" Create a "quickrun" configuration if not found. ("quickrun" is a watchdogs
" dependency providing a high-level API to "vimproc").
if !exists('g:quickrun_config')
    let g:quickrun_config = {}
endif

" Highlight lines containing syntax errors.
let g:hier_enabled = 1

" Configure core watchdogs settings, including:
"
" * 'outputter/quickfix/open_cmd', preventing watchdogs from opening a quickfix
"   window after each syntax check. Syntax results will be displayed in the
"   current buffer (e.g., via highlighting) and statusline instead.
let g:quickrun_config['watchdogs_checker/_'] = {
  \ 'outputter/quickfix/open_cmd': '',
  \ 'hook/hier_update/enable_exit': 1,
  \ 'hook/qfstatusline_update/enable_exit': 1,
  \ 'hook/qfstatusline_update/priority_exit': 4,
  \ 'hook/unite_quickfix/enable_failure': 1,
  \ 'hook/unite_quickfix/enable_success': 1,
  \ 'hook/unite_quickfix/unite_options': '-no-quit -no-empty -auto-resize -resume -buffer-name=quickfix',
  \ 'runner/vimproc/updatetime': 40,
  \ }

" ....................{ SYNTAX CHECK ~ watchdogs : python  }....................
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

" ....................{ SYNTAX CHECK ~ watchdogs : stop    }....................
" Configure watchdogs with the prior "quickrun" configuration.
let s:hooks = neobundle#get_hooks('vim-watchdogs')
function! s:hooks.on_source(bundle)
    call watchdogs#setup(g:quickrun_config)
endfunction

" Syntax check on buffer writes.
let g:watchdogs_check_BufWritePost_enable = 1 

" Syntax check on user inactivity.
" let g:watchdogs_check_CursorHold_enable = 1

" Syntax check the current buffer if *NOT* already running such check. Yes,
" watchdogs should define such function on your behalf. It doesn't. So be it.
function! s:bundle_watchdogs_run()
    if exists(":WatchdogsRunSilent")
        if exists("*quickrun#is_running")
            if quickrun#is_running()
                return
            endif
        elseif g:watchdogs_quickrun_running_check
            return
        endif

        WatchdogsRunSilent -hook/watchdogs_quickrun_running_checker/enable 0
    endif
endfunction

" Perform syntax checking on any of the following events in buffers with any of
" the following filetypes:
"
" * On entering buffers (e.g., creating new files, reading existing files,
"   switching back to previously opened buffers).
" * On leaving Insert mode.
" * On Normal mode changes.
augroup bundle_watchdogs
    autocmd!
    autocmd BufEnter,InsertLeave,TextChanged * call <SID>bundle_watchdogs_run()
augroup END

" ....................{ TAGS                               }....................
" Vim supports tags for a wide variety of languages, many of which are
" unsupported by "Exuberant Ctags" and hence require manual intervention below
" (e.g., JavaScript). For canonical documentation on doing so, see:
" 
"   https://github.com/majutsushi/tagbar/wiki
"
" Despite the URL, such documentation is independent of the "tagbar" plugin.
" Indeed, such URL should be considered required reading on tags configuration.

" ","-delimited list of filenames from which tags will be read. Vim iteratively
" searches such list relative to the current directory for the first such file
" that exists, replacing "./" by the current directory and recursing
" indefinitely upward for filenames suffixed by ";".
set tags=./.tags;

" ....................{ TAGS ~ easytags                    }....................
" Common easytags commands include:
"     :UpdateTags            " update tags only for the current file
"     :UpdateTags -R {path}  " update tags recursively for the passed path

"FIXME: O.K.; I didn't quite get it, but now I (disappointingly) do. The auto-
"updating performed by easytags only calls :UpdateTags without arguments and
"hence fails to perform recursively, requiring project-specific key bindings to
"manage the latter. But the existing "indexer" plugin *APPEARS* to already
"implement such functionality, rendering everything below a bit moot. *sigh*
"FIXME: That said, it's *NOT* hard at all to just define a new leader-driven
"command running an appropriate ":UpdateTags -R {path}".
"FIXME: Right. "indexer" hasn't been updated in a year and a half. Given the
"fragility of tags-related functionality, it would be poor judgement to switch
"to a functionally dead plugin. Consequently, let's go with the leader-driven
"command for the moment *OR* perhaps just enabling
""let g:easytags_autorecurse = 1" on opening a file residing under a known
"project. Yes! The latter is, clearly, the way to go, and should be existing
"functionality in "easytags". But it isn't, so we'll have to gin up a solution.
"That done, we'll pretty much have the "ctags" vim solution we always wanted.
"FIXME: Or perhaps such functionality has already been implemented by now? Look
"into this, please. It's been over a year since we last examined this.

" Since easytags is loaded lazily, defer its configuration until loaded.
let s:hooks = neobundle#get_hooks('vim-easytags')
function! s:hooks.on_source(bundle)
    " Due to an unresolved issue in easytags itself, automatic tag highlighting
    " is currently inordinantely slow. Until resolved, disable such automation.
    let g:easytags_auto_highlight = 0

    " Directory to which filetype-specific global tags will be written. This is
    " only a fallback for buffers in which project-local tags cannot be written
    " (e.g., due to insufficient user permissions).
    let g:easytags_by_filetype = g:my_cache_dir . 'tags'

    " Automatically read project-local tags found according to option "tags" and
    " write such tags to the current directory if not found.
    let g:easytags_dynamic_files = 2

    " For efficiency, highlight tags with an external Python script rather than
    " pure Vimscript.
    let g:easytags_python_enabled = 1

    " Since "ctags" is no longer actively released (and in any case is predicate
    " on regex heuristics rather than deterministic parsing), prefer
    " language-specific commands producing "ctags"-compatible output to "ctags".
    "
    " Note that keys are lowercase "ctags" rather than vim filetypes (e.g.,
    " "c++" rather than "cpp"). To list all available such filetypes, run:
    "
    "     >>> ctags --list-languages
    "     >>> ctags --list-maps
    let g:easytags_languages = {
      \ 'ruby': {
      \     'cmd': 'ripper-tags',
      \     'args': [],
      \     'fileoutput_opt': '-f',
      \     'stdout_opt': '-f-',
      \     'recurse_flag': '-R'
      \     }
      \ }
endfunction

" ....................{ VCS ~ git : fugitive               }....................
" Define the following new commands:
"
" * GreviewUnstaged(), opening a new vertically_split diff of the working tree
"   against the index (e.g., for reviewing all unstaged changes).
" * GreviewStaged(), opening a new vertically_split diff of the index against
"   the current HEAD (e.g., for reviewing all staged changes).
command GreviewUnstaged :Git! diff
command GreviewStaged :Git! diff --staged

" ....................{ FIXES                              }....................
"FIXME: Actually, this strikes me as a poor idea. Use the 0 register, instead.
" Prevent "x" from overwriting the default register by forcing it to cut into
" the blackhole register _ instead.
"noremap x "_x

" Prevent "p" from repasting the currently selected text in visual mode. See
" http://marcorucci.com/blog/#visualModePaste for additional discussion.
xnoremap p "_c<Esc>p

" ....................{ CLEANUP                            }....................
" For safety, undefine previously defined variables.
unlet s:hooks

" When reloading Vim, reconfigure all bundles *AFTER* defining all on_source()
" hooks for such bundles above.
if !has('vim_starting')
    call neobundle#call_hook('on_source')
endif

" --------------------( WASTELANDS                         )--------------------