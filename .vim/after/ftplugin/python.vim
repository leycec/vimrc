" ====================[ text.vim                           ]====================

" ....................{ FORMAT                             }....................
" Identify "#"-prefixed words as comment leaders. By default, "python-mode" only
" identifies "# "-prefixed words to be comment leaders -- which, given our glut
" of "#FIXME" comments, is considerably less helpful.
setlocal comments=:#,fb:-

" --------------------( WASTELANDS                         )--------------------
" autocmd BufEnter * :syntax sync fromstart
