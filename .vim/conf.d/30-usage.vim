scriptencoding utf-8
" --------------------( LICENSE                           )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                          )--------------------
" Non-theme configuration, configuring Vim and plugin functionality pertaining
" to actual usage rather than aesthetic style.

"FIXME: "python-mode" provides Rope support, which we should both learn and
"configure appropriately. Rope is basically PyCharm for Vim, providing deep
"introspection, analysis, and refactoring of Python on a project-wide basis from
"within Vim -- without use of external tag files. Yeah; it's friggin' sweet.
"See: https://github.com/klen/python-mode

" ....................{ AUTOCOMMANDS                      }....................
" Number of milliseconds before Vim invokes the "CursorHold" autocommand,
" conditionally required by some plugins (e.g., Spelunker) to perform dynamic
" background operations. As the default value of 4000ms produces a noticeable
" delay in performing these operations, we considerably reduce the default.
set updatetime=512

" ....................{ BUFFERS                           }....................
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

" ....................{ CACHING                           }....................
" ","-delimited list of context persisted for the current editing session.
" Dismantled, this is:
"
" * "%", saving all buffers and restoring such buffers when Vim is run without
"   file arguments.
" * "<", saving and restoring at most the passed number of lines for registers.
" * "/", saving and restoring at most the passed number of search patterns.
" * "'", saving and restoring marks for at most the passed number of files.
" * "h", preventing search matches highlighted under the prior session from
"   being highlighted on restoring such session.
" * "s", *NOT* saving or restoring items (currently, only registers) larger
"   than the passed number of kilobytes.
" * "n", persisting all such metadata to and from the passed filename.
let &viminfo = '%,<1024,/64,''64,h,s8,n' . g:our_cache_dir . '/viminfo'

" ....................{ CACHING ~ backup                  }....................
" Backup files to the directory specified below.
set backup

" Directory persisting backups of edited files to corresponding files. Since
" Vim offers a builtin means of uniquifying swap and undo but *NOT* backup
" files, we unroll our own for the latter below.
let &backupdir = g:our_backup_dir

augroup our_backup_uniquification
    autocmd!

    "FIXME: The directory separator "/" is clearly POSIX-specific, but we
    "currently have no idea how to generalize this to the Windows directory
    "separator "\". Such is code life.

    " Uniquify the basename of the backup file corresponding to the current
    " file *BEFORE* backing up such file *BEFORE* ovewriting such file with the
    " contents of the current buffer. Specifically, to ensure the uniqueness of
    " all backup files in the backup directory, each such file's filetype is
    " the absolute path of the parent directory of the corresponding file with
    " all directory separators "/" replaced by "%" (e.g., when edited,
    " "/the/pharmacratic/inquisition.ott" will be backed up as
    " "~/.vim/cache/backup/inquisition.ott%the%pharmacratic"). While the
    " resulting basenames are less than ideal, they *ARE* guaranteeably unique
    " in the filesystem namespace and hence satisfy basic requirements.
    autocmd BufWritePre *
      \ let &backupext = substitute(expand('%:p:h'), '/', '%', 'g')
augroup END

" ....................{ CACHING ~ swap                    }....................
" Directory persisting swap files (i.e., recoverable backups) of edited files
" to corresponding files. To ensure the uniqueness of such files in such
" directory, such directory is suffixed by "//"; in this case, the basenames of
" swap files will be the absolute paths of the original files with all
" directory separators (e.g., "/" on POSIX-compatible systems) replaced by "%".
let &directory = g:our_swap_dir . '//'

" ....................{ CACHING ~ undo                    }....................
" See section "HISTORY" for related settings.

" If Vim supports undo persistence...
if has('persistent_undo')
    " Directory persisting the undo history trees of edited files to
    " corresponding files. See above for further details on "//".
    let &undodir = g:our_undo_dir . '//'
    set undofile
endif

" ....................{ CACHING ~ view                    }....................
" The following logic is highly inspired by Yichao Zhou's compact
" "restore_view" plugin available at:
"     http://www.vim.org/scripts/download_script.php?src_id=22634
"
" This plugin itself was highly inspired by the corresponding Vim wiki page at:
"     http://vim.wikia.com/wiki/Make_views_automatic

" If Vim supports view persistence...
if has('mksession')
    " Directory persisting views.
    let &viewdir = g:our_view_dir

    " Blacklist of Vim-compatible regular expressions matching the absolute
    " paths of all files to *NOT* persist views for. All other files will have
    " views persisted for.
    let g:our_unviewable_filename_regexes = []

    " Prevent Vim from persisting the current working directory (CWD) of the
    " current Vim process with views. By default, Vim silently (...typically
    " confusingly) changes the CWD on restoring each view. Bad idea is bad.
    set viewoptions=cursor,folds,slash,unix

    " By default, Vim requires views be managed manually. Since automating such
    " management is both trivial and essential to sanity, do so.
    augroup our_view_automation
        autocmd!

        " Serialize the current state of the current buffer window on leaving
        " that window to disk, overwriting any previously saved state if any.
        " Dismantled, this is:
        "
        " * "?*", matching only named buffers and hence excluding the unnamed
        "   buffer created by Vim when run without arguments.
        "
        " The "BufWinLeave" event is explicitly avoided here, as leveraging
        " that event here induces errors when closing the current buffer and
        " the next buffer is nameless.
        autocmd BufWritePre,BufWinLeave ?*
          \ if vimrc#is_buffer_viewable() |
          \     silent! mkview |
          \ endif

        " Deserialize the prior state of the current buffer window on entering
        " that window, overwriting the prior saved state of that window if any.
        " To avoid conflicts with plugin-specific autocommands attempting to
        " also restore buffer, view, and/or session state, the "VimEnter"
        " rather than standard "BufWinEnter" event is hooked.
        " autocmd BufWinEnter ?*
        autocmd VimEnter ?*
          \ if vimrc#is_buffer_viewable() |
          \     silent! loadview |
          \ endif
    augroup END
endif

" ....................{ CLIPBOARD                         }....................
" There exist two fundamentally orthogonal types of "clipboards":
"
" * The system clipboard, accessible outside of Vim via the customary keyboard
"   shortcuts (e.g., <Ctrl-v> to paste the contents of such clipboard).
" * The X11 primary selection, accessible outside of Vim via the mouse,
"   whereby:
"   * Selecting a substring of text implicitly yanks that substring into the
"     primary selection.
"   * The right mouse button pastes such substring from the primary selection.
"
" Under X11, both cliboards are available. Under all other windowing systems,
" only the system clipboard is available. Accessing either requires Vim to have
" been compiled with the corresponding features. If:
"
" * The "+clipboard" feature is available:
"   * The system clipboard is accessible via the "*" register.
"   * But the "-xterm_clipboard" feature is unavailable, the system clipboard
"     is also accessible via the "+" register.
" * The "+xterm_clipboard" feature is available, the xterm-specific primary
"   selection is accessible via the "+" register.

" Alias the anonymous register (i.e., the default register for yanks, puts, and
" cuts) to whichever of the "*" and "+" registers apply to the current Vim.
" Yanking, putting, or cutting text without specifying a register yanks, puts,
" or cuts such text into the corresponding clipboard.
"
" If both registers apply, the "+" register takes precedence and hence is
" usually preferable. While yanking text without specifying a register yanks
" such text into both clipboards, putting or cutting text without specifying a
" register puts or cuts such text *ONLY* into the primary selection.
if has('clipboard')
    if has('unnamedplus')
        set clipboard=unnamed,unnamedplus
    else
        set clipboard=unnamed
    endif
elseif has('unnamedplus')
    set clipboard=unnamedplus
endif

" ....................{ COMMENTS                          }....................
" Filetype-specific comment settings. See the "FORMATTING" section below for
" related formatting settings.
augroup our_filetype_comments
    autocmd!

    " Parse "#" characters prefixing any words as comment leaders regardless
    " of whether such characters are immediately followed by whitespace. By
    " default, the plugins for the following filetypes only parse "#"
    " characters immediately followed by whitespace as comment leaders --
    " which, given our glut of "#FIXME" comments, is less than helpful.
    "
    " This option is a comma-delimited string list of all comment leaders, each
    " formatted as "{flags}:{string}", where:
    "
    " * "{flags}" is an undelimited character list of boolean flags modifying
    "   the parsing of this comment leader from Vim's default behaviour.
    " * "{string}" is the typically unquoted string of all characters
    "   comprising this comment leader *EXCLUDING* suffixing whitespace. If
    "   such whitespace is required, specify the "b" flag instead.
    "
    " Dismantled, this is:
    "
    " * ":#", defining "#" to be a comment leader with default flags and hence
    "   *NOT* requiring suffixing whitespace.
    "
    " Note that this option must set *AFTER* loading the following filetypes,
    " which are thus omitted here:
    "
    " * "python", handled by the third-party "python-mode" plugin.
    " * "dosini", handled by the official "dosini" plugin.
    "
    " For further details, see ":help format-comments".
    autocmd FileType ebuild,sh setlocal comments=:#,fb:-
augroup END

" ....................{ COMMENTS ~ tcomment               }....................
"FIXME: Configure us up the bomb. Yes, we went there.

" ....................{ DELETING                          }....................
"FIXME: Specifically? What does this do? I like it, but I'd like to know more.

" Sanitize <Backspace>.
set backspace=indent,eol,start

" ....................{ DIFFING                           }....................
" Enable the following diffing options by default:
"
" * "filler", display filler lines (i.e., contextual lines whose sole purpose
"   is to synchronize vertically-split diff buffers).
" * "vertical", opening "diff" mode with vertical rather than horizontal
"   splits.  (Horizontal splits? Seriously, Bram. Who does that? *NO ONE*.
"   That's who.)
set diffopt=filler,vertical

" Define the DiffSelf() command to review all unsaved changes in the current
" buffer by diffing the current buffer against the corresponding file if any.
command DiffSelf call vimrc#diff_buffer_current_with_file_current()

" ....................{ EXPLORING ~ unite                 }....................
" Common Unite-based exploration commands include:

" ....................{ EXPLORING ~ files                 }....................
" Common file exploration commands include:
"     :VimFiler         " run vimfiler

" ....................{ FILETYPE ~ markdown : gabrielelana}....................
" Disable Jekyll-specific Markdown syntax highlighting.
let g:markdown_include_jekyll_support = 0

" ....................{ FILETYPE ~ markdown : tpope       }....................
" Tim Pope's Markdown plugin. While no longer used, there's little harm in
" preserving the following variable.

" List of all "fenced languages" in Github-flavored Markdown code blocks. The
" opening delimiter "```" of such blocks may be suffixed by a string signifying
" the language the following block should be syntax highlighted as, in which
" case this plugin recognizes and syntax highlights such blocks accordingly.
"
" If the Github- and hence Linguist-specific language name differs from the
" corresponding Vim filetype, the former must be explicitly mapped to the
" latter with an "="-delimited item; else, simply listing such name suffices.
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

" For readability, indent "*"-prefixed list items by two rather than the
" default four spaces: e.g.,
"
"     * This is...
"       * good.
"     * This is...
"         * not good, however.
let g:vim_markdown_new_list_item_indent = 2

" ....................{ FILETYPE ~ markdown : preview     }....................
" Prevent "markdown-preview" from implicitly opening and closing preview
" windows on entering and leaving Markdown buffers.
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 0

" Prevent "markdown-preview" from implicitly scrolling preview windows on
" scrolling Markdown buffers.
let g:mkdp_preview_options = {
    \ 'disable_sync_scroll': 1,
    \ }

" Print the URL of the Markdown preview page on opening a preview window.
let g:mkdp_echo_preview_url = 1

" Refresh the current Markdown preview only on saving the Markdown buffer
" associated with this preview *OR* leaving Insert mode. By default,
" "markdown-preview" refreshes this preview on all edits and cursor movements.
let g:mkdp_refresh_slow = 1

" ....................{ FILETYPE ~ pymode                 }....................
" Core Python support via the "python-mode" ("pymode") plugin.

" If Vim was compiled with Python 3 support *AND* "python3" is in the current
" ${PATH}, Python 3 is available and presumably preferred to 2. In such case,
" enable Python 3- rather than 2-specific functionality. For backward
" compatibility, the latter is the default.
"
" Ideally, "python-mode" would conditionally detect which Python functionality
" to enable based on the shebang line prefixing the current file buffer. Since
" it does *NOT*, this is the next-best thing in GrungyTown.
let g:pymode_python = g:our_is_python3 ? 'python3' : 'python'

" Disable all folding functionality in "python-mode".
let g:pymode_folding = 0

" Prevent "python-mode" from performing syntax checks (e.g., on buffer write),
" as "ale" already does so in a frankly superior manner.
let g:pymode_lint = 0

" Disable support for rope, a Python refactoring library. In theory, enabling
" such support would be preferable. In practice, the time (and possibly space)
" costs of enabling such support appear to be prohibitive. The proprietary IDE
" PyCharm appears to be both more trustworthy *AND* performant than rope for
" industrial-strength Python refactoring, sadly.
let g:pymode_rope = 0
"let g:pymode_rope = 1

" If the current user is the superuser, prevent Rope from recursively searching
" for ".ropeproject" directories in parent directories of the current directory
" if the latter contains no ".ropeproject" directory. Since the superuser
" typically edits top-level files containing no such directory, this recursion
" typically induces a recursive search of the entire filesystem hanging Vim.
if g:our_is_superuser
    let g:pymode_rope_lookup_project = 0
" Else, permit Rope to perform this recursion.
else
    let g:pymode_rope_lookup_project = 1
endif

" Disable Rope-based autocompletion on typing <.> in Insert mode. As of this
" writing, this behaviour appears to either be broken or conflict with another
" plugin also hooking Insert mode events (e.g., "watchdogs").
let g:pymode_rope_complete_on_dot = 0

" Prevent "python-mode" from implicitly trimming trailing whitespace. By
" default, "python-mode" does so, which is frankly horrible, because doing so
" often produces semantically invalid code. See also:
"     https://github.com/python-mode/python-mode/issues/912
"let g:pymode_trim_whitespaces = 0

" ....................{ FILETYPE ~ pymode : syntax        }....................
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
" these strings be reformatted as triple-quoted strings with dedendation: e.g.,
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

" ....................{ FILETYPE ~ rest                   }....................
" Core reStructuredText (reST) support via the "riv" plugin and previewing via
" the "InstantRst" plugin.
"
" Common riv commands include:
"     :RivInstruction     " list all available Riv.vim options
"     :RivCheatSheet      " read the 'reStructuredText Cheatsheet'
"     :RivPrimer          " read 'A ReStructuredText Primer'
"     :RivSpecification   " read the 'reStructuredText Specification'
"     :RivQuickStart      " read the 'QuickStart With Riv'
"     :RivInstruction     " read the 'Riv Instructions'
"
" Likewise, common InstantRst commands include:
"     :InstantRst         " preview current reST buffer
"     :InstantRst!        " preview all reST buffers
"     :StopInstantRst     " stop previewing current reST buffer
"     :StopInstantRst!    " stop previewing all reST buffers

" Reduce the CPU intensiveness of reST buffer previews. While helpful, these
" previews are non-essential and hence deprioritizable.
let g:instant_rst_slow = 1

" Prevent "riv" from causing spurious "maxmempattern" errors on highlighting
" reST links by disabling such support entirely. Note that this issue occurs
" regardless of the fact we've already dramatically increased the
" "maxmempattern" setting below, implying that this is our only recourse. Ergo,
" this arguably constitutes an unresolved "riv" issue. See also:
"     https://github.com/gu-fan/riv.vim/issues/144
let g:riv_link_cursor_hl = 0

" ....................{ FOLDING                           }....................
" Disable folding globally. However, intentionally or accidentally performing a
" folding action (e.g., by typing <zc>) implicitly undoes this by re-enabling
" folding globally. Hence, this alone is *NOT* sufficient to disable folding.
set nofoldenable

" Disable folding, part deux. This ensures that even in the event of Vim re-
" enabling folding on a particular buffer, folding will appear to remain
" disabled. (Arguably the worst "feature" that Vim foists on hapless users.)
set foldlevelstart=99
set foldlevel=99

" ....................{ FORMAT                            }....................
" Insert one rather than two spaces after sentence-terminating punctuation
" (e.g., ".", "?", "!") when performing a join command (e.g., "J", "gq").
set nojoinspaces

" Filetype-specific formatting. For safety, append and shift list
" "formatoptions" with the "+=" and "-=" operators rather than overwriting such
" list (and hence sane Vim defaults) with the "=" operator. See ":h fo-table".
"
" For efficiency, formatting specific to single filetypes is isolated into the
" "after/ftplugin" directory.
augroup our_filetype_format
    autocmd!

    " Enable comment-aware text formatting for *ALL* code-specific filetypes
    " (i.e., filetypes supporting comments), regardless of whether the plugins
    " configuring these filetypes do so. Note that this option must set *AFTER*
    " loading the following filetypes, which are thus omitted here:
    "
    " * "zeshy", handled by the third-party "zeshy" plugin. This formatting is
    "   already applied by this plugin and need not be repeated here.
    autocmd FileType
      \ dosini,ebuild,fstab,gentoo-make-conf,gitcommit,markdown,mkd,perl,python,sh,vim,yaml,zsh
      \ call vimrc#sanitize_code_buffer_formatting()

    " Enable comment-aware text formatting for *ALL* code-specific
    " pseudo-filetypes. For as yet unknown reasons, these filetypes do *NOT*
    " appear to be set at a sane time by either Vim or their corresponding
    " filetype plugins and hence *MUST* be manually matched by filetype.
    autocmd BufWinEnter,BufNewFile
      \ *.css
      \ call vimrc#sanitize_code_buffer_formatting()
augroup END

" ....................{ FORMAT ~ table                    }....................
" Markdown- and reStructuredText-formatted table support.
"
" Common "vim-table-mode" commands include:
"     <Leader>tm (:TableModeToggle)       " enable on-the-fly table editing
"     ||                                  " add automatic row separators
"     [|                                  " move left one table cell
"     ]|                                  " move right one table cell
"     {|                                  " move up one table cell
"     }|                                  " move down one table cell
"     i|                                  " move inner table cell
"     a|                                  " move around table cell
"     <Leader>tdd                         " delete current table row
"     <Leader>tdc                         " delete current table column
"     <Leader>tic                         " insert table column after cursor
"     <Leader>tiC                         " insert table column before cursor
"     <Leader>tr (:TableModeRealign)      " reformat current table
"     <Leader>tt (:Tableize)              " reformat CSV data into table
"     <Leader>T (:Tableize/{char})        " reformat {char}-delimited data
"
" See also:
" * "Creating table on-the-fly," terse usage instructions.
"   https://github.com/dhruvasagar/vim-table-mode#creating-table-on-the-fly

" ....................{ GLOBBING                          }....................
" When globbing, ignore files matching the following glob patterns.
set wildignore=*.class,*.dll,*.exe,*.gif,*.jpg,*.o,*.obj,*.png,*.py[co],*.so,*.swp

" ....................{ HISTORY                           }....................
" See section "TEMPORARY PATHS" for related settings.

" Maximum number of per-session ex commands and search patterns to persist.
set history=1000

" Maximum number of per-buffer undos to persist.
set undolevels=1000

" ....................{ INDENTATION                       }....................
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

" ....................{ INDENTATION ~ filetype            }....................
" Filetype-specific indentation.
augroup our_filetype_indentation
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
    autocmd FileType * setlocal shiftwidth=4 softtabstop=4 tabstop=4 expandtab

    " For markup-heavy filetypes (e.g., YAML), reduce the default tab width.
    " Since markup tends to heavily nest, this helps prevent overly long lines
    " and hence improve readability.
    autocmd FileType yaml setlocal shiftwidth=2 softtabstop=2 tabstop=2

    " For markup-obsessed filetypes (e.g., XML), minimize the default tab width
    " to the minimum non-zero width (i.e., 1). XML, what ills do thou wrought?
    autocmd FileType html,xml setlocal shiftwidth=1 softtabstop=1 tabstop=1

    " For filetypes in which tabs are significant (e.g., ebuilds, makefiles),
    " bind <Tab> to insert tabs rather than spaces.
    autocmd FileType ebuild,make setlocal noexpandtab
augroup END

" ....................{ INDENTATION ~ vim                 }....................
" Indent "\"-prefixed continuation lines by half of the shiftwidth.
let g:vim_indent_cont = 2

" ....................{ LINTING ~ ale                     }....................
" Asynchronous Linting Engine (ALE) provides asynchronous syntax checking.

" Minimum number of milliseconds after the current buffer is modified to
" require ALE delay *BEFORE* relinting this buffer. Since the default of 200
" milliseconds tends to induce visible slowdown under CPU load and/or
" computationally expensive linters, we approximately double this default.
"
" See also:
"
" * ":help g:ale_lint_on_text_changed", a downstream setting governing when
"   asynchronous linting delayed by the current setting occurs.
let g:ale_lint_delay = 512

" ....................{ LINTING ~ ale : line              }....................
" Unconditionally enable ALE-informed syntax highlighting. See "20-theme" for
" the definitions of all ALE-specific syntax groups.
let g:ale_set_highlights = 1

" ....................{ LINTING ~ ale : sign              }....................
" Unconditionally disable ALE's usage of the sign gutter, which:
"
" * Conflicts with that of other bundles -- usually, version control.
" * Is well-known to impose significant performance penalties in ALE.
" * Is redundant, given the line-oriented highlight groups defined above.
let g:ale_set_signs = 0

" Unconditionally display the sign gutter, regardless of whether the current
" buffer exhibits one or more linter failures.
let g:ale_sign_column_always = 1

" Prefer single-character Unicode symbols to double-character ASCII strings.
let g:ale_sign_error   = '»'
let g:ale_sign_warning = '–'

" ....................{ LINTING ~ ale : speed             }....................
" Maximum number of ALE-specific signs per buffer. Since signs are well-known
" to impose significant performance penalties in ALE, instructing ALE to *NOT*
" maintain an excessive number of signs is a simple (albeit effective) approach
" to optimizing ALE performance.
let g:ale_max_signs = 16

" Maximum filesize in bytes to lint with ALE. Files larger than this size will
" be silently ignored by ALE. Note that a filesize of:
"
" * 200000 bytes (i.e., 200Kb) approximately corresponds to a maximum line
"   length of 5,000 lines per buffer.
let g:ale_maximum_file_size = 200000

" Minimum number of milliseconds before ALE echoes messages for issues near the
" current cursor. Increasing this delay improves performance at a cost of
" reducing responsiveness.
let g:ale_echo_delay = 128

" ....................{ LINTING ~ ale : lang              }....................
" Dictionary mapping from each lintable filetype to the list of all linters
" with which to asynchronously lint buffers of that filetype. Since ALE
" defaults to linting filetypes *NOT* specified by this dictionary with all
" linters available for that filetype, each filetype of interest should
" typically be explicitly mapped to exactly one desirable linter here or below.
let g:ale_linters = {
  \ 'php': ['php'],
  \ }

" If the Perl Critic linter is available, lint Perl with this linter.
"
" Note that ALE also supports "perl" itself as a linter, disabled by
" default due to "perl" insecurely executing "BEGIN" and "CHECK" blocks.
" Indeed, we concur and thus avoid enabling this linter.
if executable('perlcritic')
    let g:ale_linters['perl'] = ['perlcritic']
endif

" ....................{ LINTING ~ ale : lang : python     }....................
" If Python 3 support is available...
if g:our_is_python3
    "FIXME: Uncomment the following after ALE correctly supports "pyflakes".
    "For unknown reasons, the newly defined "pyflakes" linter fails to
    "highlight syntax errors or warnings -- despite correctly identifying those
    "errors and warnings in the status bar. *sigh*

    " If the "pyflakes" linter is available, prefer linting Python with *ONLY*
    " this linter: the most minimalist (and thus efficient) Python linter.
    " if executable('pyflakes') || executable('pyflakes3')
    "     let g:ale_linters['python'] = ['pyflakes']
    " " Else if the "pylint" linter is available...
    " elseif executable('pylint')

    if executable('pylint')
        " Fallback to linting Python with this linter.
        let g:ale_linters['python'] = ['pylint']

        " Configure "pylint" to:
        "
        " * "--disable=", squelching ignorable:
        "   * "R", refactor complaints.
        "   * "C", convention complaints.
        "   * "E0401" (i.e., "import-error"), preventing "pylint" from
        "     flagging importable modules that, for whatever reason, are
        "     unimportable by "pylint". (Probably a "sys.path" issue.)
        "   * "E0603" (i.e., "undefined-all-variable"), preventing "pylint"
        "     from flagging "__all__" lists referencing undefined attributes.
        "     While a list referencing an undefined attribute would typically
        "     be harmful, the "__all__" dunder list global is itself
        "     sufficiently harmful to warrant unconditional ignoring.
        "   * "E0611" (i.e., "no-name-in-module"), preventing "pylint" from
        "     flagging attributes imported from C extensions.
        "   * "E0702" (i.e., "raising-bad-type"), preventing "pylint" from
        "     flagging "raise" statements whose exception instances "pylint"
        "     erroneously claims (without evidence) to be "None".
        "   * "E1101" (i.e., "no-member"), preventing "pylint" from
        "     flagging dynamically synthesized attributes (notably, the
        "     "setter" decorator of properties).
        "   * "E1133" (i.e., "not-an-iterable"), preventing "pylint" from
        "     erroneously flagging types that support iteration as not
        "     supporting iteration (notably, iterable cached properties).
        "   * "E1135" (i.e., "unsupported-membership-test"), preventing
        "     "pylint" from erroneously flagging types that support the "in"
        "     operator as not supporting that operator (notably, cached
        "     properties).
        "   * "E1136" (i.e., "unsubscriptable-object"), preventing "pylint"
        "     from erroneously flagging types defining the __class_getitem__()
        "     dunder method as unsubscriptable. Since most builtin types now
        "     define this dunder method under Python >= 3.9, "pylint" behaves
        "     erroneously over a vast swath of objects when this is enabled.
        "   * "W0107" (i.e., "unnecessary-pass"), preventing "pylint" from
        "     flagging all "pass" statements preceded by docstrings in
        "     placeholder classes and functions.
        "   * "W0122" (i.e., "exec-used"), preventing "pylint" from flagging
        "     all exec() statements. While commonly undesirable, there exist
        "     numerous valid use cases for exec() statements. Flagging all such
        "     calls is unhelpful.
        "   * "W0123" (i.e., "eval-used"), preventing "pylint" from flagging
        "     all eval() statements. While commonly undesirable, there exist
        "     numerous valid use cases for eval() statements. Flagging all such
        "     calls is unhelpful. *shaking_my_psoriatic_head*
        "   * "W0125" (i.e., "using-constant-test"), preventing "pylint" from
        "     flagging conditional statements branching on constant values
        "     (e.g., "if False:"). These statements are of use in selectively
        "     squelching *OTHER* ignorable warnings emitted by Python linters
        "     (notably, unused import warnings).
        "   * "W0201" (i.e., "attribute-defined-outside-init"), preventing
        "     attributes initialized in methods transitively called by
        "     __init__() methods and hence guaranteed to be defined on object
        "     instantiation from being incorrectly flagged as problematic.
        "   * "W0212" (i.e., "protected-access"), preventing "pylint" from
        "     flagging attempts to access protected attributes (i.e.,
        "     attributes whose names are prefixed by "_") from external
        "     objects. While such access *CAN* be problematic, there exist
        "     numerous valid use cases for doing so. In particular,
        "     implementing comparison operators (e.g., the __ge__ special
        "     method defining an object's implementation for the >= operator)
        "     commonly requires accessing one or more protected attributes of
        "     the passed object; since that object is commonly an instance of
        "     the same class, no privacy violation commonly exists. Since
        "     "pylint" unconditionally flags *ALL* such access regardless of
        "     context, the only sane decision is *NOT* to play the game at all.
        "   * "W0221" (i.e., "arguments-differ"), preventing "pylint" from
        "     flagging subclass methods whose signature differs from that of
        "     superclass methods of the same name. While such differences *CAN*
        "     be problematic in the uncommon edge case of multiple inheritance,
        "     there exist numerous valid use cases for doing so.
        "   * "W0511" (i.e., "fixme"), preventing "pylint" from flagging all
        "     "FIXME" comments. *sigh*
        "   * "W0603" (i.e., "global-statement"), preventing "pylint" from
        "     flagging declaration of "global" variables from within callables.
        "     While commonly undesirable, there exist numerous valid use cases
        "     for global variables. Flagging all such uses is unhelpful.
        "   * "W0613" (i.e., "unused-argument"), preventing "pylint" from
        "     flagging callables whose arguments are *NOT* referenced by their
        "     implementations. While unused attributes (especially imports and
        "     local variables) do typically imply a cause for concern, unused
        "     callable arguments are a valid common occurrence (e.g., due to
        "     abstract base classes) and hence best ignored.
        "   * "W0702" (i.e., "bare-except"), preventing "catch:" clauses from
        "     raising ignorable warnings. ("pylint", you are clearly retarded.)
        "   * "W0703" (i.e., "broad-except"), preventing "catch Exception:"
        "     clauses from raising ignorable warnings. (Are you kidding me?)
        "   This preserves only verifiably fatal errors and non-fatal severe.
        "   warnings (e.g., unused local variable).
        " * "--jobs=2", minimally parallelizing "pylint" execution.
        let g:ale_python_pylint_options =
          \ '--disable=R,C,E0401,E0603,E0611,E0702,E1101,E1133,E1135,E1136,W0107,W0122,W0123,W0201,W0212,W0221,W0511,W0603,W0613,W0702,W0703'

        "FIXME: Replace the above "pylint" configuration by that defined below
        "*AFTER* ALE supports the "--jobs=" option. As of this writing, setting
        "this option induces infinite loops in ALE and/or "pylint". (Woops.)
        " let g:ale_python_pylint_options =
        "   \ '--disable=R,C,E0401,E0611,E0702,E1101,E1133,E1135,W0122,W0201,W0212,W0511,W0603,W0613,W0702,W0703 ' .
        "   \ '--jobs=2'
    " Else if the "flake8" linter is available...
    elseif executable('flake8')
        " Fallback to linting Python with this linter.
        let g:ale_linters['python'] = ['flake8']

        " Preserve only fatal errors (F) and non-fatal severe warnings (E).
        let g:ale_python_flake8_options = '--select=F,E'
    endif
endif

" ....................{ MACROS                            }....................
" When executing macros, redraw the screen only after such macros complete.
set lazyredraw

" ....................{ MODELINES                         }....................
" Check the first 8 lines of new buffers for Vim modelines. By default, Gentoo
" and other distributions disable such checking. Typically, modelines resemble:
"
"     # Declare this file to be of Vim type "conf", regardless of filename.
"     # vim: set filetype=conf:
set modeline
set modelines=8

" ....................{ MOUSE                             }....................
" Enable terminal mouse support.
set mouse=a

" ....................{ NAVIGATING                        }....................
" Constrain the cursor to actual characters for all modes *EXCEPT* (i.e.,
" enable virtual editing for) the following:
"
" * "block", Visual block mode.
" * "insert", Insert mode.
" * "all", all modes.
" * "onemore", permit the cursor to only move past the end of the line.
set virtualedit=block

" Define context-sensitive window navigation commands.
command SwitchWindowUp    call vimrc#switch_window('k')
command SwitchWindowDown  call vimrc#switch_window('j')
command SwitchWindowLeft  call vimrc#switch_window('h')
command SwitchWindowRight call vimrc#switch_window('l')

" ....................{ REFORMATTING ~ vim-autoformat     }....................
" Permit the Python-specific "autopep8" reformatter to aggressively reformat
" long lines. While "vim-autoformat" provides default options for such
" reformatter under "plugin/defaults.vim", "autopep8" senselessly ignores
" option "--max-line-length" unless at least two aggressive options are passed.
let g:formatprg_python = 'autopep8'
let g:formatprg_args_expr_python = '"- --experimental --aggressive --aggressive --aggressive ".(&textwidth ? "--max-line-length=".&textwidth : "")'

" ....................{ REMOTING                          }....................
" Prevent the default "netrw" plugin from littering working trees with
" ".netrwhist" files caching history and bookmarks for remotely edited files.
" While it would probably be better to reconfigure "netrw" to add such files to
" the "~/.vim/cache" subdirectory, it's unclear how to effect that; so, we
" currently disable them entirely.
let g:netrw_dirhistmax = 0

" ....................{ SEARCHING                         }....................
" Highlight all matching substrings in the current buffer.
set hlsearch

" Search incrementally (i.e., as you type).
set incsearch

" Maximum memory usage in kilobytes to constrain regular expression-based
" pattern matching by. The default of 1000Kb induces syntax highlighting
" failure on large buffers with the following error message:
"     E363: pattern uses more memory than 'maxmempattern'
let g:maxmempattern = 4096
" let g:maxmempattern = 2048

" Search for all-lowercase regexes case-insensitively and all other regexes
" (i.e., regexes containing at least one uppercase character) case-sensitively.
"
" Do *NOT* globally enable "ignorecase", as doing so unhelpfully applies to
" substitutions, which should generally be searched for case-sensitively.
" Instead, selectively enable such option only for searching with "\c" above.
set smartcase

" ....................{ SEARCHING ~ magic                 }....................
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

" ....................{ SEARCHING ~ replace               }....................
" Enable global substitutions by default (i.e., implicitly append "/g" to all
" substitutions). Appending "/g" to a substitution now disables global
" substitution, as expected.
set gdefault

" ....................{ SPELLING                          }....................
" Common spelling commands include:
"     ]s        " jump to the next misspelled word
"     [s        " jump to the prior misspelled word
"     zg        " mark a misspelled word at the cursor as good
"     zug       " unmark a misspelled word at the cursor as good

"FIXME: Sadly, Spelunker is even less intelligent than Vim's default naive
"spell checker. Whereas the latter is configurable to spell check *ONLY*
"comments and strings in code, the former has no means of doing so.
" Disable Vim's default naive spell checker in favour of Spelunker, a
" third-party spell checker intelligently aware of common code conventions like
" CamelCase, snake_case, acronyms, URLs, and so on.
" set nospell

" Spell check in English when enabled on a buffer-specific basis.
set spelllang=en

"FIMXE: Auto-regenerate the corresponding binary "en.utf-8.spl" cache file when
"older than the plaintext "en.utf-8.add" file. Vim uses the latter to generate
"the former, but only does so on adding new words to the latter. This is
"non-ideal, since Vim will fail to regenerate the former on external changes to
"the latter (e.g., git synchronization across machines). See also:
"    https://vi.stackexchange.com/a/5052/16249
"    https://github.com/micarmst/vim-spellsync

" Absolute filename of the user-specific file to store misspelled words
" manually marked by the user as *NOT* misspelled (e.g., with <zg>), whose
" basename *MUST* be of the format "{language}.{encoding}.add".
"
" Note that, for unknown reasons, Vim *ALWAYS* returns the empty string for
" "set spellfile?" until the first manual user interaction with the spelling
" system (e.g., with <zg), at which point "set spellfile?" shows this filename.
let g:spellfile = g:our_spell_dir . '/en.utf-8.add'

" Avoid highlighting any of the following as misspelled words:
"
" * URIs (i.e., words prefixed by one or more alphanumeric characters followed
"   by a "://" delimiter), strongly inspired by this blog post:
"     http://www.panozzaj.com/blog/2016/03/21/ignore-urls-and-acroynms-while-spell-checking-vim/
" * Acronyms (i.e., words comprised of only three or more uppercase
"   alphanumeric characters optionally followed by an "s"), strongly inspired
"   by the same blog post.
"
" Note that these highlight groups only apply to a subset of filetypes. For
" more complex filetypes (e.g., Python), a "containedin=" clause explicitly
" referencing the type of parent highlight group containing these child
" highlight groups is required. To prevent filetype plugins from ignoring these
" highlight groups, these groups *MUST* be added to a custom
" "~/.vim/after/syntax/{filetype.vim}" filetype plugin rather than listed here.
" See also this explanatory StackOverflow answer:
"     https://vi.stackexchange.com/a/4003/16249
syntax match NoSpellUri '\w\+:\/\/[^[:space:]]\+' contains=@NoSpell

"FIXME: Seemingly unneeded. Perhaps Vim now ignores acronyms by default?
" syntax match NoSpellAcronym '\<\(\u\|\d\)\{3,}s\?\>'  contains=@NoSpell

" Filetype-specific spelling settings.
augroup our_filetype_spelling
    autocmd!

    " Enable spell checking in all buffers of the following filetypes.
    autocmd FileType gitcommit,markdown,mkd,python,rst,text,vim,yaml
      \ setlocal spell
augroup END

" ....................{ SPELLING ~ spelunker              }....................
"FIXME: Disabled, as Spelunker is even less intelligent than the default spell
"checker. (See above for voluminous details.)
let g:enable_spelunker_vim = 0

" Spell check only words displayed in the current window (i.e., type "2")
" rather than all words across the current buffer (i.e., type "1").
"
" Note that Spelunker implements type "2" with the "CurserHold" autocommand,
" whuch Vim delays by "updatetime" milliseconds.
" let g:spelunker_check_type = 2

" ....................{ TAGS                              }....................
" Vim supports tags for a wide variety of languages, many of which are
" unsupported by "Exuberant Ctags" and hence require manual intervention below
" (e.g., JavaScript). For canonical documentation on doing so, see:
"   https://github.com/majutsushi/tagbar/wiki
"
" Despite the URL, such documentation is independent of the "tagbar" plugin.
" Indeed, such URL should be considered required reading on tags configuration.

" ","-delimited list of filenames from which tags will be read. Vim iteratively
" searches such list relative to the current directory for the first such file
" that exists, replacing "./" by the current directory and recursing
" indefinitely upward for filenames suffixed by ";".
set tags=./.tags;

" ....................{ TAGS ~ easytags                   }....................
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

"FIXME: Refactor to use the new dein-specific "hook_post_source" formalism.
" Configure easytags when lazily loaded.
"if dein#tap('vim-easytags')
"    function! dein#hooks.on_post_source(plugin)
"        " Due to an unresolved issue in easytags itself, automatic tag
"        " highlighting is currently inordinantely slow. Until resolved, disable
"        " such automation.
"        let g:easytags_auto_highlight = 0
"
"        " Directory to which filetype-specific global tags will be written. This
"        " is only a fallback for buffers in which project-local tags cannot be
"        " written (e.g., due to insufficient user permissions).
"        let g:easytags_by_filetype = g:our_cache_dir . '/tags'
"
"        " Automatically read project-local tags found according to option "tags"
"        " and write such tags to the current directory if not found.
"        let g:easytags_dynamic_files = 2
"
"        " For efficiency, highlight tags with an external Python script rather
"        " than pure Vimscript.
"        let g:easytags_python_enabled = 1
"
"        " Since "ctags" is no longer actively released (and in any case is
"        " predicate on regex heuristics rather than deterministic parsing),
"        " prefer language-specific commands producing "ctags"-compatible output
"        " to "ctags".
"        "
"        " Note that keys are lowercase "ctags" rather than vim filetypes (e.g.,
"        " "c++" rather than "cpp"). To list all available such filetypes, run:
"        "
"        "     >>> ctags --list-languages
"        "     >>> ctags --list-maps
"        let g:easytags_languages = {
"          \ 'ruby': {
"          \     'cmd': 'ripper-tags',
"          \     'args': [],
"          \     'fileoutput_opt': '-f',
"          \     'stdout_opt': '-f-',
"          \     'recurse_flag': '-R'
"          \     }
"          \ }
"    endfunction
"
"    call dein#untap()
"endif

" ....................{ VCS ~ fugitive                    }....................
" Common default mappings in the ":Gstatus" buffer include:
"
"     g?     " show this help
"     <C-N>  " next file
"     <C-P>  " previous file
"     <CR>   " |:Gedit|
"     -      " |:Git| add
"     -      " |:Git| reset (staged files)
"     a      " Show alternative format
"     ca     " |:Gcommit| --amend
"     cc     " |:Gcommit|
"     ce     " |:Gcommit| --amend --no-edit
"     cw     " |:Gcommit| --amend --only
"     cva    " |:Gcommit| --verbose --amend
"     cvc    " |:Gcommit| --verbose
"     D      " |:Gdiff|
"     ds     " |:Gsdiff|
"     dp     " |:Git!| diff (p for patch; use :Gw to apply)
"     dp     " |:Git| add --intent-to-add (untracked files)
"     dv     " |:Gvdiff|
"     O      " |:Gtabedit|
"     o      " |:Gsplit|
"     P      " |:Git| add --patch
"     P      " |:Git| reset --patch (staged files)
"     q      " close status
"     r      " reload status
"     S      " |:Gvsplit|
"     U      " |:Git| checkout
"     U      " |:Git| checkout HEAD (staged files)
"     U      " |:Git| clean (untracked files)
"     U      " |:Git| rm (unmerged files)
"     .      " enter |:| command line with file prepopulated

" Define the following new commands:
"
" * GdiffUnstaged(), reviewing all unstaged changes by diffing the working
"   tree against the index.
" * GdiffStaged(), reviewing all staged changes by diffing the index against
"   the current HEAD.
command GdiffUnstaged :Git! diff
command GdiffStaged :Git! diff --staged

" ....................{ VCS ~ vimgitlog                   }....................
"FIXME: Currently disabled, due to "vimgitlog" being basically broken. That
"said, it's the only currently maintained Vim plugin purporting to do this.

" " Display the tree (value 2) rather than log (value 1) view by default. While
" " the latter would probably be preferable, "vimgitlog" fails hard when that is
" " the case. Unsurprisingly, installation instructions advise this default.
" let g:GITLOG_default_mode = 2
"
" " Ignore files with the following filetypes.
" let g:GITLOG_ignore_suffixes=['swp', 'pyc', 'pyo']
"
" " Ignore directories with the following basenames.
" let g:GITLOG_ignore_directories = ['.git', '__pycache__']
"
" " Enable tree walking, substantially optimizing the tree view.
" let g:GITLOG_walk_full_tree = 1

" ....................{ PROJECTS                          }....................
" Associate project roots (i.e., top-level subdirectories of the current user's
" home directory, containing all content for such projects) with project-
" specific settings, typically enforcing coding conventions.
augroup our_project_settings
    autocmd!

    " Associate all shell scripts in all ".oh-my-zsh" and "oh-my-zsh"
    " subdirectories of the current user's home directory with:
    "
    " * zsh mode.
    " * Two-space indentation.
    "
    " Since oh-my-zsh is *NEVER* installed as a system-wide package, this logic
    " should (theoretically) generalize to other developers as well.
    autocmd BufNewFile,BufRead ~/{*/,}{.,}oh-my-zsh/{*/,}*.sh
      \ setlocal filetype=zsh shiftwidth=2 softtabstop=2 tabstop=2
augroup END
