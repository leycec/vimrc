" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Theme configuration, specifying both the current colour and statusline themes
" *AND* configuring Vim and bundle functionality pertaining to aesthetic style.

"FIXME: Create mode-aware cursors (i.e., cursors changing color based on the
"current Vim mode) via the "gcr" option.

" ....................{ CORE                               }....................
" Enable filetype-dependent syntax highlighting *AFTER* NeoBundle logic above.
syntax on

" Prefer light-on-dark to dark-on-light color schemes *BEFORE* selecting color
" schemes leveraging such settings (e.g., "solarized").
set background=dark

" When running macros, only redraw the screen *AFTER* such macros complete.
set lazyredraw

" Prefix lines by line numbers.
set number

" Require at least this many lines of visible text to both precede and succeed
" the current line.
set scrolloff=3

" ....................{ CORE ~ disable                     }....................
" Do *NOT* highlight the current column or line.
set nocursorcolumn
set nocursorline

" Do *NOT* display the current mode in the command line, as the status line
" already does so in a more configurable and aesthetically pleasing manner.
set noshowmode

" ....................{ COLOUR                             }....................
" Avoid "solarized". While the author has clearly invested inordinate effort in
" designing, prosletyzing, generalizing this scheme for a wide audience and set
" of operating systems and applications, we personally find it rather abhorent.
" "solarized" adheres to a bizarre heuristic of minimizing the number of palette
" changes required to shift from a dark-on-light to light-on-dark orientation.
" While theoretically interesting, such heuristic is functionally useless in the
" real world, producing a pair of subjectively unappealing color schemes with
" minimal differences. While it's good the number of color changes between the
" two has been minimized, it's bad that the end result is as unappealing as it
" is. Indeed, such unfortunate results beg the inevitable question: why the
" popularity? The answer, we suspect, lies with both marketing and uniformity.
" The "solarized" website exceptionally well constructed; moreover, the lure of
" a "one color scheme to rule them all" ubiquity seals the deal.

"FIXME: O.K.; my current thoughts on color schemes are as follows. We should
"make either lucius *OR* desert-warm-256 our base default. We should prefer
"whichever is currently more actively updated. (Probably lucius.) Assuming
"lucius, manually replace inadvisable colors with colors from, in order:
"
"* desert-warm-256. Fantastic scheme, though just a tad behind lucius. I prefer
"  *ONLY* the following in this scheme to "lucius":
"  * The line number gutter background, which is (in desert, anyway) the same as
"    the edit window background, as it should be.
"  * The documentation color. Awesome!
"  * The comment color. Decent. We can probably do better, but even this would
"    be an improvement.
"* peaksea and/or xoria256. While not the best, both are similar enough to
"  warrant stripping colors from.
"FIXME: Actually, I'd prefer the background be translucent and "urxvt" to be
"configured such that its semi-transparent background approaches that of
"lucius. This would probably also require adopting lucius colors for urxvt's
"standard 16 colors, which I'm quite alright with.

" Colour scheme.
"
" For further details, see:
" http://www.vim.org/scripts/script.php?script_id=2536
colorscheme lucius
"colorscheme desert-warm-256

" ....................{ COLOUR ~ highlight                 }....................
" Custom highlight groups overwriting those defined by the above color scheme.
" "ctermfg" and "ctermbg" are indices in [1, 256], as visualized here:
"     http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim

" Syntax errors. Since Vim unhelpfully predefines such group with attribute
" "cterm=underline", clear such group *BEFORE* redefining such group.
hi clear SpellBad
hi SpellBad ctermfg=9 ctermbg=52 guisp=#ff5f5f
" hi SpellBad term=standout ctermfg=1 cterm=underline

" Syntax warnings.
hi clear SpellCap
hi SpellCap ctermfg=11 ctermbg=58 guisp=#5fafd7

" ....................{ EX COMMANDS                        }....................
" Ex commands are ":"-prefixed commands (e.g., ":help pattern").

" Permit menu-driven <Tab> completion of Ex commands. On the first <Tab>, Vim
" lists all matching completions. On the second <Tab>, Vim offers interactive
" selection of these completions horizontally, such that <Left> and <Right>
" iteratively select completions.
"
" Yes, this is as good as it gets. (We've googled. Extensively.)
set wildmenu
set wildmode=list:longest,full

" ....................{ HIGHLIGHT                          }....................
" Map filetypes to syntax highlighting synchronization settings. While Vim
" already maps most filetypes to such settings, their defaults often fail to
" suffice for real world files (particularly, files including lengthy comments
" and/or strings). If opening a buffer fails to properly syntax highlight the
" currently displayed region, consider increasing the number of prior lines vim
" vim parses on every buffer movement to syntax highlight such region. Note that
" large numbers (e.g., >= 2500) may result in significant slowdown.
"
" Common settings include:
"
" * "syntax sync minlines=${number_of_prior_lines}", inducing Vim to parse that
"   number of prior lines on every buffer movement.
" * "syntax sync fromstart", inducing Vim to parse from the beginning of such
"   buffer on every buffer movement. This is functionally equivalent to setting
"   "syntax sync minlines=99999". However, numerous users report such
"   synchronization to be faster under certain modes than "minlines"-style
"   synchronization.
"
" Note that the following filetypes are externally synchronized by their plugin
" and hence should *NOT* be synchronized here:
"
" * "python", by "python-mode"'s global variable "g:pymode_syntax_slow_sync".
augroup filetype_syntax
    autocmd!
    autocmd FileType html,zsh autocmd BufEnter * :syntax sync fromstart
augroup END

" ....................{ HIGHLIGHT ~ unprintable            }....................
" Syntax highlight unprintable characters. For further details, see:
" http://vim.wikia.com/wiki/Highlight_unwanted_spaces

" Display all whitespace characters specified by "listchars".
"
" Due to <who-the-hell-knows-why>, Vim silently disables "linebreak" when
" enabling this option. This option takes precedence. This is rather nice, as
" this option is generally preferable to "linebreak", which operates somewhat
" too broadly to be useful.
set list

" Whitespace characters to be displayed. Dismantled, this is:
"
" * "tab:{tabstop}{padding}", displaying tab characters as such tabstop and all
"   intermediate whitespace as such padding.
" * "trail:{string}", displaying trailing whitespace as such string.
" * "nbsp:{string}", displaying non-breaking spaces as such string.
set listchars=tab:»·,trail:·,nbsp:␣

" Avoid displaying tab characters in modes in which such characters are either
" required (e.g., ebuilds) or merely commonplace (e.g., HTML, XML).
augroup filetype_tabs
    autocmd!
    autocmd FileType ebuild,html,xml setlocal nolist
augroup END

" Highlight whitespace characters "nbsp", "tab", and "trail".
highlight SpecialKey ctermfg=240 guifg=#2c2d27

" ....................{ PROMPT                             }....................
" Do *NOT* prompt users to press <Enter> on each screen of long listings.
set nomore

" Do *NOT* "ring the bell" (e.g., audible beep, screen flash) on errors.
set noerrorbells
set novisualbell

" Abbreviate canonical Vim prompts and messages as follows:
"
" * "a", enable all of the following flags:
"   * "f", reducing "(3 of 5)" to "(file 3 of 5)".
"   * "i", reducing "[noeol]" to "[Incomplete last line]".
"   * "l", reducing "999L, 888C" to "999 lines, 888 characters".
"   * "m", reducing "[+]" to "[Modified]".
"   * "n", reducing "[New]" to "[New File]".
"   * "r", reducing "[RO]" to "[readonly]".
"   * "w", reducing:
"     * "[w]" to "written" for file write messages.
"     * "[a]" to "appended" for ':w >> file' commands.
"   * "x", reducing:
"     * "[dos]" to "[dos format]".
"     * "[unix]" to "[unix format]".
"     * "[mac]" instead of "[mac format]".
" * "o", show only reading or writing messages if both occur at once.
" * "t", truncate filenames.
" * "T", truncate messages rather than prompting users to press <Enter>.
set shortmess=aotT

" ....................{ STATUS LINE                        }....................
" Always display the status line, regardless of how many windows are open.
set laststatus=2

" ....................{ STATUS LINE ~ airline              }....................
" See also:
"
" * Airline FAQ:
"   https://github.com/bling/vim-airline/wiki/FAQ

"FIXME: We can and eventually should do significantly better. airline's default
"status line is *WAY* too verbose, displaying a variety of information either
"obtainable elsewhere or easily abbreviatable. Specifically:
"
"* Don't bother displaying how far one is through the current buffer (e.g., the
"  "50%"). That's functionally useless metadata.
"* Don't bother displaying how the current line number, which is already given
"  by the line number column.
"* Don't bother displaying the current filetype. (Maybe? Arguable.)
"* Prefix the basename of the current buffer's file by all dirnames relative to
"  the current working directory (e.g., rather than merely "test.py", display
"  "test/unit/test.py"). Interestingly, airline's tabline extension already
"  sort-of does this, but reduces directory names to the first character of
"  such names. (Which makes sense for a tabline.)
"
"Happily, airline is *VERY* and readily configurable. For details, see either
"":h airline" or:
"    https://github.com/bling/vim-airline/blob/master/doc/airline.txt

" Delimit sections by background colour changes rather than additional
" characters.
let g:airline_left_sep = ''
let g:airline_right_sep = ''

" Enable the airline-specific tabline extension, listing buffers in a new status
" line appearing above rather than below current windows.
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''

" Reduce Vim mode names in the status line to single characters.
let g:airline_mode_map = {
  \ '__' : '-',
  \ 'n' : 'N',
  \ 'i' : 'I',
  \ 'R' : 'R',
  \ 'c' : 'C',
  \ 'v' : 'V',
  \ 'V' : 'V',
  \ '' : 'V',
  \ 's' : 'S',
  \ 'S' : 'S',
  \ '' : 'S',
  \ }

"FIXME: Enable once we get such fonts (finally!) going.
" Enable Powerline-patched font support.
" let g:airline_powerline_fonts = 1

" ....................{ STATUS LINE ~ airline : section    }....................
" For a list of default values for all sections, see:
"     https://github.com/bling/vim-airline/blob/master/autoload/airline/init.vim

" Expand the center-rightmost status line section to display the current working
" directory. By default, such section displays the filetype for the current
" buffer; since such filetype rarely (if ever) changes and is readily printable
" with "set ft" when it does, this strikes us as a better use of scarce space.
let g:airline_section_x = airline#section#create_right(['%{getcwd()}'])

" Reduce the rightmost status line section to merely the current column with
" default width of two digits. All other metadata typically displayed in such
" section (e.g., line numbers) are visible elsewhere and hence redundant here.
let g:airline_section_z = airline#section#create(['%2c'])

" Configure qfstatusline when lazily loaded.
if neobundle#tap('vim-qfstatusline')
    function! neobundle#hooks.on_post_source(bundle)
        " Conditionally display a rightmost section synopsizing the line and
        " column number of the first syntax error in the current buffer.
        let g:airline_section_warning =
          \ airline#section#create(["%{qfstatusline#Update()}"])

        " Update the statusline on syntax errors.
        let g:Qfstatusline#UpdateCmd = function('airline#update_statusline')
    endfunction

    call neobundle#untap()
endif

" ....................{ WRAPPING                           }....................
" String prefixing soft-wrapped lines.
set showbreak=↳  " ↺↳↪

" Text formatting options. To permit Vim to provide improved defaults in the
" future, append and shift such list with "+=" and "-=" rather than overwriting
" such list with "=". Dismantled, this is:
"
" * "j", removing comment leaders when joining lines.
" * "n", handling numbered lists.
"
" Avoid enabling "a", automatically formatting all comments. While such option
" sounds pleasant in theory, it behaves unpleasantly destructively in practice,
" rendering most comments uneditable.
"
" Avoid enabling "t", as the current mode does so on your behalf. Comment
" autoformatting is only enabled under modes enabling "t", which includes most
" programming modes.
"
" See ":h fo-table" for further details.

" Preferred line length, respected by numerous other settings and commands
" (e.g., "gq{movement}", wrapping all text from the cursor to the end of such
" movement to this length).
set textwidth=80

" Filetype-specific wrapping.
augroup filetype_wrapping
    autocmd!

    " Visually soft-wrap lines exceeding the width of the current Vim window.
    " Rather than permanently hard-wrapping such lines by adding a newline
    " character into such buffer, this only temporarily wraps such lines in such
    " window for readability.
    "
    " Ensure this overwrites plugin defaults by setting such option *AFTER*
    " opening new buffers and hence running such plugins.
    autocmd FileType * setlocal wrap
augroup END

" ....................{ WRAPPING ~ color                   }....................
"FIXME: Such functionality behaves a bit badly, unfortunately. Since we
"highlight such column with a background color *AND* since vim color styles
"often reverse colors (e.g., for highlighting search results), this inevitably
"results in search results at or passed such column having a near-black
"foreground: unreadable! The ideal solution would be to stop using a color
"scheme that insists on reverse colors (which are terrible, anyway). Until then,
"this remains.
"FIXME: After correcting the color scheme, uncomment the next several lines.

" Display a thin vertical line at the ideal line length.
"set colorcolumn=+1

" Define the set of columns to be colored as:
"
" * The column exceeding the ideal line length (i.e., warning).
" * All columns exceeding 40 columns after the ideal line length (i.e., danger).
"let &colorcolumn="81,".join(range(120,320),",")

" Highlight such columns as a slightly lighter shade of grey than pure black.
"highlight ColorColumn ctermbg=232 guibg=#2c2d27
"highlight CursorLine ctermbg=235 guibg=#2c2d27
"highlight CursorColumn ctermbg=235 guibg=#2c2d27

" --------------------( WASTELANDS                         )--------------------
