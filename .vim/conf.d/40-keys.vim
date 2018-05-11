scriptencoding utf-8
" --------------------( LICENSE                            )--------------------
" Copyright 2015-2018 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Dotfile-specific key bindings.
"
" --------------------( BINDINGS                           )--------------------
" Vim provides the following key binding commands:
"
" * map(), recursively defining a mapping for all modes (i.e., ":map j gg"
"   followed by ":map Q j" maps both "j" and "Q" to "gg").
" * noremap(), nonrecursively defining a mapping for all modes (i.e.,
"   ":map j gg" followed by ":map W j" maps "j" to "gg" and "W" to "j").
" * cmap() and cnoremap(), recursively and nonrecursively defining a mapping for
"   ex command mode (i.e., the command prompt entered via <:>).
" * lmap() and lnoremap(), recursively and nonrecursively defining a mapping for
"   *ALL* insertion modes (e.g., ex command mode, insert mode, regexp-search
"   mode). The "l" purportedly stands for "[L]ang-Arg pseudo-mode." (Ugh.)
" * nmap() and nnoremap(), recursively and nonrecursively defining a mapping for
"   normal mode.
" * imap() and inoremap(), recursively and nonrecursively defining a mapping for
"   insert mode.
" * smap() and snoremap(), recursively and nonrecursively defining a mapping for
"   select mode.
" * vmap() and vnoremap(), recursively and nonrecursively defining a mapping for
"   visual *AND* select modes.
" * xmap() and xnoremap(), recursively and nonrecursively defining a mapping for
"   visual mode.
"
" If the first argument to any such command is "<silent>", Vim prevents that
" command from printing to the command line (e.g., search patterns).
"
" In general, prefer nonrecursive to recursive mappings. While the former behave
" exactly as specified, the behavior of the latter dynamically change depending
" on the behavior of target mappings (typically defined elsewhere). If in doubt,
" default to the nnoremap() command for defining key bindings.
"
" --------------------( BINDINGS ~ debug                   )--------------------
" To list all custom key bindings, call the ":map" Ex command with no arguments.
" To show the command associated with an existing:
"
" * Builtin key bindings, pass that binding to the ":help" Ex command (e.g.,
"   ":help dd"). Both printable (e.g., "j") and non-printable characters (e.g.,
"   "Ctrl-space") are expressed as undelimited case-insensitive arguments:
"   * <Ctrl> is expressed as "c-" or "ctrl-" (e.g., ":h c-i", ":help ctrl-i").
"   * <Alt> is expressed as "m-" or "meta-" (e.g., ":h m-a", ":help meta-a").
"   * <Shift> is expressed as "s-" or "shift-" (e.g., ":h s-o", ":help shift-o").
" * Custom key bindings, pass that binding to the ":map" Ex command (e.g., ":map
"   ,dd"). Whereas printable characters (e.g., "j") are expressed as undelimited
"   case-insensitive arguments, non-printable characters (e.g., "Ctrl-space")
"   *MUST* be expressed as "<"- and ">"-delimited case-insensitive strings:
"   * <Ctrl> is expressed as "<c-" or "<ctrl-" (e.g., ":map <c-i>").
"   * <Alt> is expressed as "<m-" or "<meta-" (e.g., ":map <m-a>").
"   * <Shift> is expressed as "<s-" or "<shift-" (e.g., ":map <s-o>").
"
" For example:
"
"     :h dd        " show the builtin command bound to the <dd> key sequence
"     :h space     " show the builtin command bound to the <space> key
"     :map ,dd     " show the custom command bound to the <,dd> key sequence
"     :map <space> " show the custom command bound to the <space> key
"
" Note that attempting to inspect either builtin Vim key bindings with ":map"
" *OR* user-defined key bindings with ":help" will erroneously yield either no
" bindings or an inapplicable binding.
"
" --------------------( DEFAULT                            )--------------------
" Vim provides the following little-known (but much-helpful) key bindings out of
" the box:
"
" * <gQ>, opening Ex mode -- also referred to as the best equivalent of a
"   Vimscript REPL in Vim.
"
" --------------------( SEE ALSO                           )--------------------
" * "conf.d/10-dein.vim", defining lazily loaded plugin-specific key bindings.
" * "after/ftplugin/rst.vim", defining reStructuredText-specific key bindings.

" ....................{ NORMAL                             }....................
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

" ....................{ EX                                 }....................
" Bind <:w!!> to reopen the current file with the superuser privelages,
" effectively mimicking "sudo !!" at the CLI.
cnoremap <silent> w!! w !sudo tee % >/dev/null

" ....................{ LEADER                             }....................
" Bind:
"
" * <,> to <leader>, the symbolic user-specific prefix for global key bindings.
" * <-> to <leader>, the symbolic user-specific prefix for buffer-local key
"   bindings.
"
" Both prefixes are guaranteed *NOT* to conflict with default Vim key bindings
" and hence provide safe "namespaces" with which to define custom key bindings.
"
" Technically, the "," prefix *DOES* conflict with a default Vim key binding
" searching backwards in the current line from a prior <t> or <f> search. In
" practice, however, this binding is used insufficiently frequently *AND* is
" sufficiently close to the home row under non-QWERTY keyboard layouts (e.g.,
" Dvorak) to justify replacement.
let mapleader=","
let maplocalleader="-"

" ....................{ LEADER ~ general                   }....................
" Bind <,vr> to reload Vim's startup scripts (e.g., this file).
nnoremap <silent> <leader>vr load-vim-script $MYVIMRC<cr>

" Bind <,u> to toggle the undo-tree panel. (Vim 7.0 generalized the undo history
" from a uniform path to branching tree.)
nnoremap <leader>u :UndotreeToggle<cr>

" ....................{ LEADER ~ colour                    }....................
" Bind <,1> to synchronize syntax highlighting in the current buffer.
nnoremap <silent> <leader>1 :call vimrc#synchronize_syntax_highlighting()<cr>

" Bind <,/> to dehighlight all terms found by the prior search. This preserves
" the search history and hence is preferable to manually searching for garbage
" strings (e.g., "/ oeuoeuoeu").
nnoremap <silent> <leader>/ :nohlsearch<cr>

" ....................{ LEADER ~ buffer                    }....................
"FIXME: This probably isn't quite right.
" Bind <,e> to open a new buffer editing a file discovered via Unite.
nnoremap <leader>e :Unite<cr>

" Bind <,w> to write the current buffer. This avoids the need to otherwise
" confirm this write with a prefixing <Enter>, reducing keystroke load.
nnoremap <leader>w :w<cr>

" ....................{ LEADER ~ plugin : ale              }....................
" Bind <,lj> and <,lk> to jump to the next and prior ALE-specific linter error
" and/or warning in the current buffer. Note that:
"
" * By ALE design, these bindings *MUST* be defined recursively.
" * For unknown reasons, these bindings *MUST* be unconditionally defined
"   regardless of whether ALE is, was, or will be lazily loaded for the current
"   buffer. Attempting to lazily define these key bindings on plugin load fails.
nmap <silent> <leader>lj <Plug>(ale_next_wrap)
nmap <silent> <leader>lk <Plug>(ale_previous_wrap)

" ....................{ LEADER ~ plugin : vcs : fugitive   }....................
" Bind <,Gu> to open a new buffer diffing the working Git tree against the index.
nnoremap <leader>Gu :GdiffUnstaged<cr>

" Bind <,Gt> to open a new buffer diffing the Git index against the current HEAD.
nnoremap <leader>Gt :GdiffStaged<cr>

" Bind <,Gs> to open a new buffer viewing and editing the Git index.
nnoremap <leader>Gs :Gstatus<cr>

" Bind <,Hs> to open a new buffer viewing and editing Mercurial's DirState.
nnoremap <leader>Hs :Hgstatus<cr>

" ....................{ LEADER ~ plugin : vcs : vimgitlog  }....................
" Bind <,Gl> to open a new buffer viewing the Git log listing all commits and
" files changed by those commits (in descending order of commit time).
nnoremap <leader>Gl :GitLog<cr>

"FIXME: Currently disabled, due to "vimgitlog" being basically broken. That
"said, it's the only currently maintained Vim plugin purporting to do this.

" nnoremap <leader>Gl :call GITLOG_ToggleWindows()<cr>
" nnoremap <leader>GL :call GITLOG_FlipWindows()<cr>

" ....................{ LEADER ~ window                    }....................
" Bind <,nd> to delete (i.e., close) the current window. This key binding has
" been selected to orthogonally coincide with the ":bd" command deleting (i.e.,
" closing) the current buffer.
nnoremap <leader>nd :wincmd q<cr>

" Bind <,no> to delete (i.e., close) all windows except the current window.
nnoremap <leader>no :only<cr>

" Bind <,nj> to either:
"
" * If a window exists under the current window, switch to that window.
" * Else, horizontally split the current window and switch to the new window
"   under the current window.
nnoremap <leader>nj :SwitchWindowDown<cr>

" Bind <,nk> to either:
"
" * If a window exists above the current window, switch to that window.
" * Else, horizontally split the current window and switch to the new window
"   above the current window.
nnoremap <leader>nk :SwitchWindowUp<cr>

" Bind <,nh> to either:
"
" * If a window exists to the left of the current window, switch to that window.
" * Else, horizontally split the current window and switch to the new window to
"   the left of the current window.
nnoremap <leader>nh :SwitchWindowLeft<cr>

" Bind <,nl> to either:
"
" * If a window exists to the right of the current window, switch to that
"   window.
" * Else, horizontally split the current window and switch to the new window to
"   the right of the current window.
nnoremap <leader>nl :SwitchWindowRight<cr>

" Bind <,nJ> to switch the window position of the current window with that of
" the bottom-most window.
nnoremap <leader>nJ :wincmd J<cr>

" Bind <,nK> to switch the window position of the current window with that of
" the topmost window.
nnoremap <leader>nK :wincmd K<cr>

" Bind <,nH> to switch the window position of the current window with that of
" the leftmost window.
nnoremap <leader>nH :wincmd H<cr>

" Bind <,nL> to switch the window position of the current window with that of
" the rightmost window.
nnoremap <leader>nL :wincmd L<cr>

" ....................{ SHAMELESS HACKAGE                  }....................
"FIXME: Actually, this strikes me as a poor idea. Use the 0 register, instead.
" Prevent <x> from overwriting the default register by forcing it to cut into
" the blackhole register _ instead.
"noremap x "_x

" Prevent <p> from repasting the currently selected text in visual mode. See
" http://marcorucci.com/blog/#visualModePaste for additional discussion.
xnoremap p "_c<Esc>p
