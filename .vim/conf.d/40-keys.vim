" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Dotfile-specific key bindings.

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
" Bind <,> to "<Leader>", a symbolic user-specific prefix for Vim key bindings.
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

" ....................{ BINDINGS ~ leader : vcs            }....................
" Bind <,Gu> to open a new buffer diffing the working Git tree against the index.
nnoremap <leader>Gu :GreviewUnstaged<cr>

" Bind <,Gs> to open a new buffer diffing the Git index against the current HEAD.
nnoremap <leader>Gs :GreviewStaged<cr>

" Bind <,Ge> to open a new buffer viewing and editing the Git index.
nnoremap <leader>Ge :Gstatus<cr>

" Bind <,He> to open a new buffer viewing and editing Mercurial's DirState.
nnoremap <leader>He :Hgstatus<cr>

" --------------------( WASTELANDS                         )--------------------
