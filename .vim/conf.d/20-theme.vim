scriptencoding utf-8
" --------------------( LICENSE                            )--------------------
" Copyright 2015-2018 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Theme configuration, specifying both the current colour and statusline themes
" *AND* configuring Vim and plugin functionality pertaining to aesthetic style.

"FIXME: Create mode-aware cursors (i.e., cursors changing color based on the
"current Vim mode) via the "gcr" option.

" ....................{ TERMINAL                           }....................
" If the following conditions all hold:
"
" * Vim autodetected the current terminal to support less than 256 colors.
" * The name of the current terminal is "xterm".
" * Bash is installed (i.e., the command "bash" is in the current ${PATH}).
" * A POSIX-compatible device node exists for the current terminal (i.e.,
"   "/dev/tty" is an existing file). Sadly, Vim provides no means of
"   distinguishing device nodes from non-device nodes.
"
" Then confirm that the current terminal actually supports less than 256 colors
" and, if this is not the case, instruct Vim of this fact.
"
" Presumably, Vim "autodetects" such quantity in a similar manner to that of the
" command "tput colors" -- which is to say, by querying the local terminfo
" database for the "Co" attribute of the terminal named "${TERM}".
" Unfortunately, such attribute is often unreliable -- especially for terminals
" named "xterm". The GNOME Terminal, for example, is named "xterm" and has a
" "Co" attribute of 8 while actually supporting 256 colors.
"
" This stems from the fact that the terminfo database associates each terminal
" name with exactly one "Co" attribute value, despite the fact that multiple
" terminals self-identifying as "xterm" support a variable number of colors
" depending on codebase, version, and compile- and runtime options. Plainly,
" this attempt to centralize all terminal metadata into a single authoritative
" database is fundamentally flawed and at the root of various ongoing issues
" with respect to Linux and BSD CLI usage. POSIX-compatible terminals *SHOULD*
" have been required to conform to some semblance of a sane runtime API
" dynamically exposing terminal metadata to end users. Indeed, even the most
" simplistic solution of a suite of well-named environment variables (e.g.,
" "${TERM_Co}") would have sufficed. Big reality fail, guys.
"
" For portability, this detection is implemented as a multiline Bash snippet
" embedded inline below. This snippet generalizes the following external source,
" for which we are indecently grateful:
"
" * Gille's stackoverflow answer, published at:
"   https://unix.stackexchange.com/a/23789/117478

if &t_Co < 256 &&
  \ $TERM == 'xterm' &&
  \ executable('bash') &&
  \ filereadable('/dev/tty')
    " Absolute path of the "bash" command in the current ${PATH}.
    let s:bash_file = exepath('bash')

    " Absolute path of the command running the current shell.
    let s:shell_old = &shell

    " Temporarily set the current shell to "bash".
    let &shell = s:bash_file

    " Dismantled, this is (in order):
    "
    " * Write the xterm-specific ANSI escape sequence "<OSC>4;255;?<BEL>" to the
    "   current terminal device. If such terminal supports the color with index
    "   255 and hence at least 256 colors, such terminal writes a string
    "   resembling "^[]4;rgb:eeee/eeee/eeee^G" to itself identifying the current
    "   color value assigned that color index; else, no string is written.
    " * If reading from the current terminal device succeeds with options:
    "   * "-d $'\a'", reading an arbitrary string delimited either by a newline
    "     *OR* by the bell character (i.e., "\a", "^G", <Ctrl-G>, <BEL>).
    "   * "-r", reading in raw mode whereby backslashes are parsed as literal
    "     backslashes rather than as character escapes or line continuations.
    "   * "-s", reading silently without echoing the read string.
    "   * "-t 0.1", waiting such number of seconds for a string matching such
    "     constraints to be written to the current terminal device before
    "     failing. Larger intervals induce non-negligible delays; smaller
    "     intervals induce race conditions. This interval strikes a delicate
    "     balance between the two.
    " * Then:
    "   * Erase the string written to the current terminal. Specifically:
    "     * Write the xterm-specific ANSI escape sequence "<CSI>1K" to such
    "       terminal, erasing from the start of the current line to the current
    "       cursor position.
    "     * Write the xterm-specific ANSI escape sequence "<CSI>0E" to such
    "       terminal, moving the cursor back to the start of the current line.
    "   * Return successful exit status.
    " * Else, return failure exit status.
    "
    " Yes, this *ACTUALLY* works. And reliably so. Exepct on ancient versions
    " of Bash (i.e., Bash < 4.0.0), which fail to support fractional seconds
    " passed to the "-t" option and hence fail with:
    "
    "     /bin/bash: line 0: read: 0.1: invalid timeout specification
    "
    " The solution, of course, is to upgrade Bash. Since ancient versions of
    " Bash suffer numerous well-known security vulnerabilities (e.g.,
    " Shellshock), this is a sanity-preserving prerequisite anyway.
    silent
      \ !printf '\e]4;255;?\a' >/dev/tty;
      \ if read -d $'\a' -r -s -t 0.1 </dev/tty; then
      \     printf '\e[1K\e[0E' >/dev/tty;
      \     exit 0;
      \ else
      \     exit 1;
      \ fi

    " If the prior command succeeded, the current terminal actually supports at
    " least 256 colors. Notify Vim of its failings.
    if ! v:shell_error
        set t_Co=256
    endif

    " Restore the current shell to the prior command.
    let &shell = s:shell_old
endif

" ....................{ CORE                               }....................
" Enable filetype-dependent syntax highlighting *AFTER* all prior dein-specific
" logic *AND* the above detection for terminal colours.
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

" Do *NOT* display the current mode in the command line, as the statusline
" already does so in a more configurable and aesthetically pleasing manner.
set noshowmode

" ....................{ COLOUR                             }....................
" Avoid "solarized". While the author has clearly invested inordinate effort in
" designing, prosletyzing, and generalizing this scheme for a wide audience and
" set of platforms and applications, we personally find it rather abhorent.
"
" "solarized" adheres to a bizarre heuristic of minimizing the number of palette
" changes required to shift from a dark-on-light to light-on-dark orientation.
" While theoretically interesting, this heuristic is functionally useless in the
" real world, producing a pair of subjectively unappealing color schemes with
" minimal differences. While it's good that the number of color changes between
" these two sub-themes is minimal, it's bad that the end result is unappealing.
" Indeed, such unfortunate results beg the inevitable question: why the
" popularity? The answer, we suspect, lies with both marketing and uniformity.
" The "solarized" website is exceptionally well-constructed; moreover, the lure
" of a "one color scheme to rule them all" ubiquity seals the deal.

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

" If the current terminal supports at least 256 colors, enable a color scheme
" requiring such support. Unfortunately, such scheme degrades to pure monochrome
" under terminals supporting less than 256 colors -- which is substantially
" worse than Vim's default color scheme. For further details, see:
" http://www.vim.org/scripts/script.php?script_id=2536
"
" Else, preserve Vim's default color scheme as is.
if &t_Co >= 256
    colorscheme lucius
endif

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
" already maps most filetypes to these settings, their defaults often fail to
" suffice for real world files (particularly, files including lengthy comments
" and/or strings). If opening a buffer fails to properly syntax highlight the
" currently displayed region, consider increasing the number of prior lines vim
" parses on buffer movements to syntax highlight that region. Note that large
" numbers (e.g., >= 2500) may result in significant slowdown, which largely
" defeats the purpose. (Get it: largely?)
"
" Common settings include:
"
" * "syntax sync minlines=${number_of_prior_lines}", inducing Vim to parse that
"   number of prior lines on every buffer movement.
" * "syntax sync fromstart", inducing Vim to parse from the beginning of this
"   buffer on every buffer movement. This is functionally equivalent to setting
"   "syntax sync minlines=99999". However, numerous users report this
"   synchronization to be faster under certain modes than "minlines"-style
"   synchronization.
"
" Filetypes intentionally excluded here include:
"
" * Python, whose "after/ftplugin" sets this synchronization.
augroup our_filetype_syntax
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
augroup our_filetype_tabs
    autocmd!
    autocmd FileType ebuild,html,xml setlocal nolist
augroup END

" Highlight whitespace characters "nbsp", "tab", and "trail".
highlight SpecialKey ctermfg=240 guifg=#2c2d27

" ....................{ PROMPT                             }....................
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

" ....................{ STATUSLINE                         }....................
" Always show the statusline regardless of the number of currently open windows.
set laststatus=2

" ....................{ STATUSLINE ~ airline               }....................
" See also:
"
" * Airline FAQ:
"   https://github.com/vim-airline/vim-airline/wiki/FAQ
" * Airline documentation:
"   https://github.com/vim-airline/vim-airline/blob/master/doc/airline.txt

"FIXME: Prefix the basename of the current buffer's file by all dirnames
"relative to the current working directory (e.g., rather than merely "test.py",
"display "test/unit/test.py"). Interestingly, airline's tabline extension
"already sort-of does this, but reduces directory names to the first character
"of such names. (Which makes sense for a tabline.)

" Airline theme, independent but ideally correlated to the Vim theme set above.
" Airline comes plugind with a variety of themes, most of which are surprisingly
" well-done. For a full list (complete with animated GIFs), see:
"     https://github.com/vim-airline/vim-airline/wiki/Screenshots
let g:airline_theme='lucius'
" let g:airline_theme='luna'
" let g:airline_theme='bubblegum'
" let g:airline_theme='ubaryd'

" To conserve statusline space, delimit sections by background colour changes
" rather than additional characters.
let g:airline_left_sep = ''
let g:airline_right_sep = ''

" To conserve statusline space, abbreviate Vim mode names by single characters.
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

" ....................{ STATUSLINE ~ airline : extension   }....................
" Show the current VCS branch if any.
let g:airline#extensions#branch#enabled = 1

" Avoid describing changes to the current VCS branch if any. Such description
" tends to be overly verbose (e.g., "+1 ~3 -1"), irrelevant, and available via
" other means, such as at the CLI prompt.
let g:airline#extensions#hunks#enabled = 0

" List all buffers in a new statusline situated *ABOVE* all other windows.
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''

"FIXME: Enable once we get such fonts (finally!) going.
" Enable Powerline-patched font support.
" let g:airline_powerline_fonts = 1

" ....................{ STATUSLINE ~ airline : section     }....................
" For a list of default values for all sections, see:
"     https://github.com/bling/vim-airline/blob/master/autoload/airline/init.vim
"
" for additional lazily loaded sections, see the addition of the following
" plugins within "10-dein.vim": "vim-qfstatusline".

" Expand the center-rightmost status line section to display the current working
" directory. By default, such section displays the filetype for the current
" buffer; since such filetype rarely (if ever) changes and is readily printable
" with "set ft" when it does, this strikes us as a better use of scarce space.
let g:airline_section_x = airline#section#create_right(['%{getcwd()}'])

" Reduce the rightmost status line section to merely the current column with a
" default width of two digits. All other metadata typically displayed in such
" section (e.g., line numbers) are visible elsewhere and hence redundant here.
let g:airline_section_z = airline#section#create(['%2c'])

" ....................{ WRAPPING                           }....................
" String prefixing soft-wrapped lines.
set showbreak=↳  " ↺↳↪

" Preferred line length, respected by numerous other settings and commands
" (e.g., "gq{movement}", wrapping all text from the cursor to the end of this
" movement to this length). Since external sources beyond our control (namely
" "/etc/vimrc") often maliciously override this option on a filetype-specific
" basis, this option is persisted to a global variable with which these sources
" are themselves overridden... by us!
let g:our_textwidth = 80
let &textwidth = g:our_textwidth

"FIXME: Apply this length to HTML and XML as well. See "after/ftplugin/yaml.vim"
"for an overly simplistic template to DRY.

" Preferred line length for data markup languages only (e.g., HTML, YAML, XML),
" thus excluding textual markup languages (e.g., Markdown, reStructuredText).
" Data markup languages tend to demand excessive indentation and hence
" additional horizontal width. For efficiency, this setting must be lazily
" applied by filetype plugins (e.g., in the "after/ftplugin" subdirectory).
" let g:our_textwidth_data_markup = 80
let g:our_textwidth_data_markup = 93

" Filetype-specific wrapping.
augroup our_filetype_wrapping
    autocmd!

    " For readability, visually soft-wrap long lines exceeding the width of the
    " current window. Do *NOT* permanently hard-wrap such lines by inserting a
    " newline character into the current buffer, which tends to have miserably
    " unexpected side effects in most languages. To ensure this overwrites
    " plugin defaults, this option is set *AFTER* opening a new buffer and hence
    " running such plugins.
    "
    " Ideally, the "linebreak" option visually soft-wrapping lines at standard
    " English word delimiters (e.g., spaces, hyphens, punctuation) would also be
    " set. Unfortunately, this option conflicts with the "list" option visually
    " distinguishing tabs from spaces. Given the non-negligible significance of
    " tabs under various modes (e.g., "ebuild", "make", "python"), the latter
    " option is arguably of greater significance and hence takes precedence.
    " Unsurprisingly, we do not even bother enabling the "linebreak" option.
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
