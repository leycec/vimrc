" ====================[ text.vim                           ]====================

" ....................{ FORMAT                             }....................
" Disable option "t" autowrapping on Markdown, which Markdown plugins tend
" to enable by default. Conventional Markdown ignores newlines and hence
" permits contiguous text in the same paragraph to be delimited by ignorable
" newlines, in which case autowrapping Markdown is safe. However, GitHub's
" increasingly popular variant of Markdown does *NOT* ignore newlines. For
" simplicity, assume all Markdown to adhere to the latter standard.
setlocal formatoptions-=t

" --------------------( WASTELANDS                         )--------------------
