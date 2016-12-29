" --------------------( LICENSE                            )--------------------
" Copyright 2015-2017 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Dotfile-specific key bindings.
"
" --------------------( DEFAULT                            )--------------------
" Vim provides the following little-known (but much-helpful) key bindings out of
" the box:
"
" * <gQ>, opening Ex mode -- also referred to as the best equivalent of a
"   Vimscript REPL in Vim.
"
" --------------------( SEE ALSO                           )--------------------
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
" Bind <:w!!> to reopen the current file for writing with superuser privelages.
cnoremap <silent> w!! w !sudo tee % >/dev/null

" ....................{ LEADER                             }....................
" Bind <,> to "<Leader>", a symbolic user-specific prefix for Vim key bindings.
" By design, this prefix is guaranteed to *NOT* conflict with default bindings,
" and hence provides a safe namespace with which to define custom key bindings.
let mapleader=","

"FIXME: This probably isn't quite right.
" Bind <,e> to open a new buffer editing a file discovered via Unite.
nnoremap <leader>e :Unite<cr>

" Bind <,s> to write the current buffer. This avoids the need to otherwise
" confirm this write with a prefixing <Enter>, reducing keystroke load.
nnoremap <leader>s :w<cr>

" Bind <,u> to toggle the undo-tree panel. (Vim 7.0 generalized the undo history
" from a uniform path to branching tree.)
nnoremap <leader>u :UndotreeToggle<cr>

" Bind <,vr> to reload Vim's startup scripts (e.g., this file).
nnoremap <silent> <leader>vr load-vim-script $MYVIMRC<cr>

" Bind <,/> to dehighlight all terms found by the prior search. This preserves
" the search history and hence is preferable to manually searching for garbage
" strings (e.g., "/ oeuoeuoeu").
nnoremap <silent> <leader>/ :nohlsearch<cr>

" ....................{ LEADER ~ vcs : fugitive            }....................
" Bind <,Gu> to open a new buffer diffing the working Git tree against the index.
nnoremap <leader>Gu :GdiffUnstaged<cr>

" Bind <,Gt> to open a new buffer diffing the Git index against the current HEAD.
nnoremap <leader>Gt :GdiffStaged<cr>

" Bind <,Gs> to open a new buffer viewing and editing the Git index.
nnoremap <leader>Gs :Gstatus<cr>

" Bind <,Hs> to open a new buffer viewing and editing Mercurial's DirState.
nnoremap <leader>Hs :Hgstatus<cr>

" ....................{ LEADER ~ vcs : vimgitlog           }....................
" Bind <,Gl> to open a new buffer viewing the Git log listing all commits and
" files changed by those commits (in descending order of commit time).
nnoremap <leader>Gl :GitLog<cr>

"FIXME: Currently disabled, due to "vimgitlog" being basically broken. That
"said, it's the only currently maintained Vim plugin purporting to do this.

" nnoremap <leader>Gl :call GITLOG_ToggleWindows()<cr>
" nnoremap <leader>GL :call GITLOG_FlipWindows()<cr>

" ....................{ LEADER ~ window                    }....................
" Bind <,wd> to delete (i.e., close) the current window. This key binding has
" been selected to orthogonally coincide with the ":bd" command deleting (i.e.,
" closing) the current buffer.
map <leader>wd :wincmd q<cr>

" Bind <,wo> to delete (i.e., close) all windows except the current window.
map <leader>wo :only<cr>

" Bind <,wj> to either:
"
" * If a window exists under the current window, switch to that window.
" * Else, horizontally split the current window and switch to the new window
"   under the current window.
map <leader>wj :SwitchWindowDown<cr>

" Bind <,wk> to either:
"
" * If a window exists above the current window, switch to that window.
" * Else, horizontally split the current window and switch to the new window
"   above the current window.
map <leader>wk :SwitchWindowUp<cr>

" Bind <,wh> to either:
"
" * If a window exists to the left of the current window, switch to that window.
" * Else, horizontally split the current window and switch to the new window to
"   the left of the current window.
map <leader>wh :SwitchWindowLeft<cr>

" Bind <,wl> to either:
"
" * If a window exists to the right of the current window, switch to that
"   window.
" * Else, horizontally split the current window and switch to the new window to
"   the right of the current window.
map <leader>wl :SwitchWindowRight<cr>

" Bind <,wJ> to switch the window position of the current window with that of
" the bottom-most window.
map <leader>wJ :wincmd J<cr>

" Bind <,wK> to switch the window position of the current window with that of
" the topmost window.
map <leader>wK :wincmd K<cr>

" Bind <,wH> to switch the window position of the current window with that of
" the leftmost window.
map <leader>wH :wincmd H<cr>

" Bind <,wL> to switch the window position of the current window with that of
" the rightmost window.
map <leader>wL :wincmd L<cr>

" ....................{ FIXES                              }....................
"FIXME: Actually, this strikes me as a poor idea. Use the 0 register, instead.
" Prevent <x> from overwriting the default register by forcing it to cut into
" the blackhole register _ instead.
"noremap x "_x

" Prevent <p> from repasting the currently selected text in visual mode. See
" http://marcorucci.com/blog/#visualModePaste for additional discussion.
xnoremap p "_c<Esc>p
