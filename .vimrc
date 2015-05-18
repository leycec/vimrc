" ====================[ .vimrc                             ]====================
"
" --------------------( SYNOPSIS                           )--------------------
" Vi[M], now with more IDE-osity. Whenever Vimscript questions arise, see:
"
" * "Learn Vimscript the Hard Way."
"   http://learnvimscriptthehardway.stevelosh.com
"
" Don't believe the title. This is absolutely the best book on Vimscript. It's
" concise; it's free; it's jocular. There is no better, nor shall be.
"
" --------------------( CHEATSHEET                         )--------------------
" Vi[M] is not necessarily the most intuitive editor, even under gVi[m].
"
"   " Show the filetype plugin associated with the current file.
"   :ft?         " this and...
"   :echo &ft    " this both work
"
" --------------------( AUTOCOMMANDS                       )--------------------
" Builtin autocmd() dynamically executes code on Vim events. Unfortunately, such
" builtin is low-level and hence does *NOT* test whether the same event handler
" has already been registered (e.g., by the same call to autocmd() after
" resourcing "~/.vimrc"). To correct this, *ALL* calls to autocmd() should be
" wrapped in an augroup with unique name specific to only a contiguous run of
" such calls. The autocmd!() call clears such group (i.e., undoes all prior
" autocmd() calls for such group), preventing duplicate registration. Such
" syntax resembles:
"
"     augroup {unique_name}
"         autocmd!
"         autocmd ...
"         autocmd ...
"     augroup END
"
" --------------------( AUTOCOMMANDS ~ events              )--------------------
" autocmd() accepts a ","-delimited list of case-insensitive event names. These
" include:
"
" * "BufNewFile", on creating a new file.
" * "BufRead" and "BufReadPost", on editing an existing file. Specifically, on
"   creating a new buffer after reading the corresponding file. Since there
"   appears to be no difference between the two, most Vim authors prefer the
"   former for brevity.
" * "BufEnter", on entering a buffer. Specifically, on creating a buffer or
"   switching to an existing buffer.
" * "FileType", on Vim setting option "filetype" for the current buffer.
"   Accepts a ","-delimited list of filetypes (e.g., "html,xhtml,xml").
" * "TextChanged", on the current buffer being modified in Normal mode.
"
" "Buf"-prefixed event names accept a single glob argument matching the name of
" such buffer -- which, assuming such buffer to be file-based, matches such
" file's absolute path (e.g., "*.html").
"
" See ":h autocmd-events" for further details.
"
" --------------------( FUNCTIONS                          )--------------------
" To call a function and ignore the return value of such function, prefix such
" call with call(); else, Vim erroneously treats such function as the name of a
" builtin Vim command and throws a fatal error on failing to find such command.
"
" --------------------( FUNCTIONS ~ scope                  )--------------------
" Vim functions are scoped by prefixing such function names with:
"
" * [A-Z], global functions accessible anywhere. Such functions must *ALWAYS*
"   begin with a capital letter to avoid conflict with Vim's standard library
"   of strictly lowercase functions. Such functions should be declared with the
"   function() builtin to ensure fatal errors when another script attempts to
"   redefine the same function.
" * "s:", script-local functions accessible anywhere in a given script file.
"   Such functions need *NOT* begin with a capital letter, since there exists no
"   possibility of conflict with Vim's standard library in this case. Such
"   functions should be declared with the function!() builtin to prevent Vim
"   from throwing fatal errors when such script is reloaded and such function
"   thus redefined.
"
" --------------------( FUNCTIONS ~ scope : mangling       )--------------------
" Technically, there *ARE* no function scopes. Internally, all Vim functions are
" global. Vim simply performs name mangling to convert between externally scoped
" function names and internally global function names. Specifically, Vim
" converts the "s:" prefixing function names (but *NOT* variable names, which
" are mangled in a different manner) to the macro "<SID>" (i.e., script
" identifier) expanding to "<SNR>{N}_", where:
"
" * "<SNR>" is a macro expanding to the prefix prefixing all script-local
"   functions (and hence serving as an ad-hoc namespace).
" * "{N}" is the unique unsigned integer arbitrarily assigned by Vim to the
"   current script.
"
" Such decrepit details are occasionally important. While ":s" is a syntactic
" construct and hence dynamically expanded at runtime, "<SID>" is a macro and
" hence statically expanded at the point of use. Hence, Vim prohibits use of
" ":s" but *NOT* "<SID>" when creating objects (e.g., autocommands, mappings)
" that will *NOT* necessarily be run in the context of the current script: e.g.,
"
"     " Note use of '<SID>' rather than ':s' below.
"     function s:foobar()
"         return ''
"     endfunction
"     :map <Leader>FB :call <SID>foobar()
"
" --------------------( VARIABLES ~ scope                  )--------------------
" Vim variables are scoped by prefixing such variable names with:
"
" * "", defaulting to either:
"   * Function-local variables if referenced in a function.
"   * Global variables otherwise.
" * "g:", global variables accessible anywhere.
" * "s:", script-local variables accessible anywhere in a given script file.
" * "l:", function-local variables only accessible in the defining function.
" * "a:", function arguments only accessible in the defining function.
" * "w:", window-local variables accessible anywhere but specific to the current
"   window (i.e., each window maintains a separate copy of such variable).
" * "t:", tab-local variables accessible anywhere but specific to the current
"   tab (i.e., each tab maintains a separate copy of such variable).
" * "b:", buffer-local variables accessible anywhere but specific to the current
"   buffer (i.e., each buffer maintains a separate copy of such variable).
" * "v:", special variables predefined by Vim. Since such variables are specific
"   to particular contexts, see the help entries for such variables.
"
" --------------------( VARIABLES ~ pseudo                 )--------------------
" Vim provides the following canonical pseudo-variables:
"
" * "&var", the Vim option named "var".
" * "&l:var", the local Vim option named "var".
" * "&g:var", the global Vim option named "var".
" * "@var", the Vim register named "var".
" * "$var", the external environment variable named "var".
"
" --------------------( VARIABLES ~ comparison             )--------------------
" Vim provides numerous variable comparison operators, two of which should
" *NEVER* appear in third-party plugins intended to be used by others:
"
" * "==" and "!=". These are the ones! *BAD*. *NEVER* use either "==" or "!="
"   in plugins. Why? Because the behaviour of both conditionally depends on user
"   settings. We're not kidding. When option "ignorecase" is disabled, both
"   behave case-sensitively; otherwise, both behave case-insensitively. While
"   this implies that both may be safely used in integer comparisons, its utter
"   fragility with respect to string comparisons suggests that both should be
"   *ALWAYS* be avoided on orthogonal grounds.
" * "==?" and "!=?", unconditionally case-insensitive comparators.
" * "==#" and "!=#", unconditionally case-sensitive comparators. These are
"   almost *ALWAYS* the ones you want.
"
" --------------------( OPERATORS ~ string list            )--------------------
" String list variable names (e.g., backupdir) may be suffixed by the following
" operators and string argument as follows:
"
" * "-=", removing the argument from such list.
" * ".=", appending the argument to such list.
" * "^=", prepending the argument to such list.
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
" If the first argument to any such command is "<silent>", Vim prevents such
" command from printing to the command line (e.g., search patterns).
"
" In general, prefer nonrecursive to recursive mappings. While the former behave
" exactly as specified, the behavior of the latter dynamically change depending
" on the behavior of target mappings (typically defined elsewhere).
"
" --------------------( BINDINGS ~ debug                   )--------------------
" To print all custom key bindings, run ":map".
"
" To print the command bound to custom key binding {binding} expressed as a "<"-
" and ">"-delimited string literal, run ":map {binding}" (e.g., ":map <ctrl-_>",
" documenting the tcomment leader). Express modifier key <Ctrl> as "<C-", <Alt>
" as "<M-", and <Shift> as "<S-".
"
" To print the command bound to default key binding {binding} expressed as an
" undelimited string literal, run ":h {binding}" (e.g., ":h CTRL-I", documenting
" that default jump list key binding). Express modifier key <Ctrl> as "C-",
" <Alt> as "M-", and <Shift> as "S-".
"
" --------------------( SEE ALSO                           )--------------------
" * "Diff and merge using vim (or gvim)", a fantastically concise cheat sheet on
"   interactive vim merging; great!
"   http://mindspill.net/computing/linux-notes/diff-and-merge-using-vim-or-gvim

"FIXME: Installing Powerline faults is troublesome due to rxvt-unicode's failure
"to support fontconfig files. (Ugh.) In light of this, we have to install a
"Powerline-patched variant of DejaVu Sans Mono. But that's not quite enough. If
"you consider infinality hinting and so forth, you quickly realize we can't just
"replace our normal DejaVu Sans Mono with the Powerline-patched variant; rather,
"we have to provide the latter as a backup to the former. See the awesome
"comment below for exactly how to go about this:
"https://github.com/Lokaltog/powerline/issues/121#issuecomment-12734261

"FIXME: Probably the sanest set of Vim defaults I've yet tripped across:
"   https://github.com/justinforce/dotfiles/blob/master/files/vim/vimrc
" * Wait. No. *THIS* is the sanest set. In fact, the fantastically concise site
"   accompanying the following Vim configuration framework is reason alone to
"   sift through its codebase. Fantastic stuff. Basically, install pretty much
"   everything listed on the main page:
"   http://vim.spf13.com/
"   Do *NOT*, however, switch to such a framework. As one stackexchange poster
"   put it: "Finally, Vim 'distributions' like spf-13 lure you with a quick
"   install and out of the box settings, but you pay the price with increased
"   complexity (you need to understand both Vim's runtime loading scheme and the
"   arbitrary conventions of the distribution) and inflexibility (the
"   distribution may make some things easier, but other things very difficult)."
"   Another poster then replied: "Yes, there's a lot of weirdness going on
"   here... SPF-13 is useful so far to get introduced to things, but I am
"   running into lots of problems indeed."
" * Consensus has it: the ultimate everything-switcher (e.g., buffers, files) is
"   "Unite." Nice, eh? See the following recent (as of this writing!) blog posts
"   for further details:
"   http://www.codeography.com/2013/06/17/replacing-all-the-things-with-unite-vim.html
"   http://eblundell.com/thoughts/2013/08/15/Vim-CtrlP-behaviour-with-Unite.html
" * Install CSApprox (i.e., Color Scheme approximator), a rather wicked CLI-only
"   plugin "gracefully degrading" GUI color schemes for use with the 6x6x6 color
"   cube on 256-color terminals:
"   http://www.vim.org/scripts/script.php?script_id=2390
"   After installing CSApprox, fix our use of "highlight" styles below. Find all
"   instances of "cterm" and replace hard-code indices into the 256-color
"   table with human-readable color names.
" * This is probably the canonical introduction to getting a decent Vim up and
"   running. Awesome Github-hosted discussion complete with screen captures:
"   http://statico.github.com/vim.html
" * O.K.; install the following plugins, which I've determined to be both
"   actively maintained and effectively essential for IDE-like behavior:
"   fugitive ~ http://www.vim.org/scripts/script.php?script_id=2975
"   tComment ~ http://www.vim.org/scripts/script.php?script_id=1173
"   YankRing ~ http://www.vim.org/scripts/script.php?script_id=1234
"   SuperTab ~ http://www.vim.org/scripts/script.php?script_id=1643
" * There seems to be something awry with my "asciidoc" plugin. It appears to
"   have a bad pattern implementation, as it keeps spitting out
"   "maxmempattern" errors on editing "README" or "TODO" files. (Ugh.)
"FIXME: It looks like the venerable "Powerline" has been replaced by "Airline":
" "The author of the original vim-powerline plugin deprecated it in favor of
"  Python-based powerline that covers much more than just Vim. Unfortunately,
"  the old plugin isn’t maintained any more and the new one is a big project
"  with currently 192 open issues and 25 open pull requests. Fortunately,
"  Bailey Ling stepped up and wrote a complete replacement called vim-airline
"  that is lighter than powerline and written in pure Vimscript."
"Alternately, numerous Redditors online increasingly prefer "lightline", a
"lightweight alternative. Suspicion has it that we'd prefer "lightline" as well,
"particularly as most Japanese plugins provide implicit support for "lightline"
"but *NOT* "airline" or "powerline".

" ....................{ DEBUGGING                          }....................
" Uncomment the following two lines to append critical debug messages to the
" following log file. After debugging, recomment such lines. The same effect
" is also achievable by running "vim" at the CLI as follows:
"     >>> vim -V9"${HOME}/.vim/cache/vim.log"
" set verbose=9
" set verbosefile=~/.vim/cache/vim.log

" ....................{ DEPENDENCIES                       }....................
" Recursively source all user-specific Vim startup scripts (i.e., ".vim" files
" under "~/.vim/conf.d"). Such scripts are globbed lexicographically and hence
" may be ordered with numeric prefixes. Such subdirectory and hence scripts are
" ignored by Vim by default and hence specific to this root startup script.
"
" Technically, Vim already performs a similar command on startup (e.g.,
" "runtime! plugin/**/*.vim"), implying that moving ".vimrc" and all dependent
" scripts into "~/.vim/plugin" should suffice to provide the same logic.
" Unfortunately, there exist numerous gotchas relating to the fundamental
" difference between ".vimrc"-centric scripts and plugins preventing the former
" from being treated as the latter. While the exact nature of such differences
" remains in dispute, their existence is trivially demonstrable by renaming
" "~/.vim/conf.d" to "~/.vim/plugin". (Yeah. Don't do that again.)
runtime! conf.d/**/*.vim

" --------------------( WASTELANDS                         )--------------------
"runtime! ~/.vim/module/**/*.vim
"runtime! expand("~/.vim/module/") . "*.vim"

"FUXME: Somewhat non-ideal. Ideally, "zeshy" buffers should have filetype
""zeshy". This will require cloning the set of "zsh"-specific files bundled with
"Vim into "zeshy" analogues (installable with a Gentoo ebuild, of course!).

" " * "zeshy". "zeshy" buffers have filetype "zsh" but (due to extensive normal and
" "   global aliasings) fail to conform to "zsh" syntax. To avoid spurious error
" "   messages on such buffers, disable active syntax checking on all buffers of
" "   filetype "zsh".
" let g:syntastic_mode_map = {
"   \ 'mode': 'active',
"   \ 'passive_filetypes': ['zsh'] }

" --------------------( VARIABLES ~ assignment             )--------------------
" Vim provides numerous variable assignment operators:
"
" * "=:",

" Disable comment autoformatting for plaintext files.
" set formatoptions-=t

" Check for updates to both NeoBundle and installed plugins *AFTER* configuring
" all prior NeoBundle settings.
" NeoBundleUpdate

 " *AFTER* configuring all prior NeoBundle settings
"   default "magic" syntax, this constraint is understandable (if onerous). To
"   circumvent this safely, remap search and substitution key prefixes to prefix
"   all interactively typed regexes with "\v."

"FUXME: Neither of the following two work. Thanks, online dotfiles!
" cnoremap     %s/     %s/\v
" cnoremap '<,'>s/ '<,'>s/\v

"FUXME: Annoyingly, we can't seem to alter Vim's auto-indentation of
"continuation lines. Googling failed us on this one, sadly.
"autocmd FileType vim setlocal cinoptions=+0.5s

" Bind <,w> to map to <C-w>, the key chord prefixing all window commands. Given
" my slight RSI, leader-prefixed commands are preferable to key chords.
" nnoremap <leader>w <C-w>

" Bind <F2> to toggle paste-sensitivity. This is bound to a function key rather
" than prefixed by <leader> to allow toggling within insert mode.
" set pastetoggle=<F2>

" ....................{ FILETYPE ~ zeshy                   }....................
"FUXME: Shift such code into a new zeshy vim plugin: e.g., at
""~/zsh/zeshy/vim/zeshy.vim".

" Associate filetype ".zeshy" with zeshy mode.
" autocmd BufNewFile,BufRead *.zeshy setlocal filetype=zeshy

"FUXME: *ALL* instances of "autocmd FileType" should be shifted to filetype-
"specific startup scripts under "~/.vim/after/ftplugin/" (e.g.,
" "~/.vim/after/ftplugin/ebuild.vim"), ensuring that default filetype plugins of
"the same name bundled either with Vim or a NeoBundle plugin are overwritten by
"settings in our filetype plugins. Indeed, one can also save filetype plugins to
" "~/.vim/ftplugin/", but that ensures the former overwrite the latter, which is
"probably very unhelpful.

" * Install Pathogen, the ultimate Vim plugin manager. Dead simple, as it
"   should be. See: http://www.vim.org/scripts/script.php?script_id=2332
"   Recommended by numerous bloggers: e.g.,
"   http://nvie.com/posts/how-i-boosted-my-vim

" Bind <Tab> to insert this many spaces.
" set softtabstop=4
" 
" " Bind "<<" and ">>" to shift by this many spaces.
" set shiftwidth=4
" 
" " Width of tab characters (i.e., '\t').
" set tabstop=4

" * "\c" when searching but *NOT* substituting, enabling case-insensitivity. See
"   "smartcase" below for further details.
" nnoremap       /       /\v\c

"autocmd BufNewFile,BufRead * if &filetype == "" | setlocal filetype=text | endif
" set ignorecase

" ....................{ FILETYPE ~ markdown : plasticboy   }....................
" plasticboy's Markdown plugin. Common interactive commands include:
"
"     ]]       go to next header
"     [[       go to prior header
"     ][       go to next sibling header (if any)
"     []       go to prior sibling header (if any)
"     ]c       go to current header
"     ]u       go to parent header (up)

" Disable Markdown-specific folding. (Thanks. No thanks.)
" let g:vim_markdown_folding_disabled=1

" Disable auto-formatting options for plaintext files. Dismantled, this is:
"
" * "c", preventing plaintext preceded by a comment leader from being treated as
"   comments and auto-wrapped.

    "FUXME: Enable recursion (i.e., automatically generate tags for all files in
    "subdirectories of the current directory). This is inherently dangerous,
    "however, and hence should *NOT* be enabled globally. Consider editing a
    "file directly under "/etc" or "/usr", for example.
    "FUXME: Hmm. Why can't easytags just enable recursion if a project-local
    "tags file is found? That would be the sensible thing to do, I imagine.
    "FUXME: Honestly, this one simple failing suggests "easytags" may not be the
    "ideal tag updater. Examine the "indexer" plugin.
"   let g:easytags_autorecurse = 1

" where "<Ctrl-_>" is literally
" that key combination rather than the string literal "Ctrl-_").
"
" To print the command bound to default symbolic key binding {symbolic-binding},
" run ":h {binding}" (e.g., ":h CTRL-I", documenting that default jump list key
" binding). Modifier key <Ctrl> is symbolized as "CTRL-".

" Common key binding commands include:
"
"     :map      " show all manual key bindings

" Prevent tComment from defining additional bindings prefixed by "<Leader>_".
"let g:tcommentMapLeader2 = ''

" Buffer commenting/uncommenting.
"NeoBundleLazy 'tomtom/tcomment_vim', {'autoload': { 'commands': [
"            \ 'TComment', 'TCommentAs', 'TCommentBlock', 'TCommentInline',
"            \ 'TCommentRight' ] }}

"FUXME: 
" Bind <,c> to the tcomment leader prefix. While tcomment provides variables for
" automating such bindings, such bindings are only available after loading
" tcomment *AND* overly awkward to type under dvorak (e.g., <,__>, toggling
" comments. To fix such issues, manually bind tcomment functionality as follows:
"
" * <,cc>, toggling c
"exec 'noremap <silent> '. g:tcommentMapLeader2 .'_ :TComment<cr>'
"    if g:tcommentMapLeader2 != ''
"        exec 'noremap <silent> '. g:tcommentMapLeader2 .'_ :TComment<cr>'
"        exec 'xnoremap <silent> '. g:tcommentMapLeader2 .'_ :TCommentMaybeInline<cr>'
"        exec 'noremap <silent> '. g:tcommentMapLeader2 .'p vip:TComment<cr>'
"        exec 'noremap '. g:tcommentMapLeader2 .'<space> :TComment '
"        exec 'xnoremap <silent> '. g:tcommentMapLeader2 .'i :TCommentInline<cr>'
"        exec 'noremap <silent> '. g:tcommentMapLeader2 .'r :TCommentRight<cr>'
"        exec 'noremap '. g:tcommentMapLeader2 .'b :TCommentBlock<cr>'
"        exec 'noremap '. g:tcommentMapLeader2 .'a :TCommentAs '
"        exec 'noremap '. g:tcommentMapLeader2 .'n :TCommentAs <c-r>=&ft<cr> '
"        exec 'noremap '. g:tcommentMapLeader2 .'s :TCommentAs <c-r>=&ft<cr>_'
"    endif

"let g:tcommentMapLeader2 = '<Leader>c'
" ....................{ STARTUP ~ variables                }....................
" Hooks for the plugin being currently configured.
"let s:hooks = ""

" While unite *CAN* be loaded lazily, proper use of unite effectively requires
" upfront configuration calling unite functions. Unconditionally load unite to
" render such functions accessible below.
"NeoBundle 'Shougo/unite.vim'

" Exploring.
"NeoBundleLazy 'Shougo/unite.vim', { 'autoload': {
"            \ 'commands': ['Unite', 'UniteResume'] }}

" For efficiency, such plugins should be
" lazily loaded (i.e., autoloaded) on first loading a file of such filetype.

"FUXME: Neither of the two approaches works. Why?
"autocmd FileType ebuild,html,xml set listchars=trail:·,nbsp:␣
"autocmd FileType ebuild,html,xml set listchars-=tab:»·

" Map filetypes to vim-specific buffer types:
"
" * "pac", proxy auto-config files for configuring URL-specific browser proxy
"   behavior via dynamically interpreted JavaScript.
"autocmd BufNewFile,BufRead *.pac set syntax=pac

" Note Vim supports automatic de-tabbing of files with ":retab" and disabling of
" auto-indendation when pasting mouse text with "set paste".

" ....................{ LINE WRAPPING ~ movement           }....................
" Map /c to toggle line wrap mode. Defaults to disabled. When enabled, the
" movement keys move by displayed line rather than actual line; this permits
" movement across long lines in a convenient manner.
"FUXME: Key binding doesn't work. Call it manually, for now. *sigh*
"noremap <silent> <Leader>w :call ToggleWrap()<CR>
"function ToggleWrap()
"    if &wrap
"        echo "Wrap OFF"
"        setlocal nowrap
"        set virtualedit=all
"        silent! nunmap <buffer> <Up>
"        silent! nunmap <buffer> <Down>
"        silent! nunmap <buffer> <Home>
"        silent! nunmap <buffer> <End>
"        silent! iunmap <buffer> <Up>
"        silent! iunmap <buffer> <Down>
"        silent! iunmap <buffer> <Home>
"        silent! iunmap <buffer> <End>
"    else
"        echo "Wrap ON"
"        setlocal wrap linebreak nolist
"        set virtualedit=
"        setlocal display+=lastline
"        noremap  <buffer> <silent> <Up>   gk
"        noremap  <buffer> <silent> <Down> gj
"        noremap  <buffer> <silent> <Home> g<Home>
"        noremap  <buffer> <silent> <End>  g<End>
"        inoremap <buffer> <silent> <Up>   <C-o>gk
"        inoremap <buffer> <silent> <Down> <C-o>gj
"        inoremap <buffer> <silent> <Home> <C-o>g<Home>
"        inoremap <buffer> <silent> <End>  <C-o>g<End>
"    endif
"endfunction

" default, no rotate, no scrolling
"let g:bufferline_rotate = 0

"NeoBundle 'mbbill/undotree'       " navigate undo history tree
"FUXME: Vim is distinctly slower now. I suppose it was inevitable, but I still
"dislike it. Let's uncover the culprit with isolation, shall we?

"\   'name' : 'vimproc',
"\   'path' : 'Shougo/vimproc',
"\   'description' : 'Asynchronous execution plugin for Vim',
"\   'author' : 'Shougo',
"\   'website' : 'https://github.com/Shougo/vimproc',
"\   'script_type' : 'plugin',
"NeoBundle 'vim-scripts/wombat256.vim'

"let g:airline#extensions#syntastic#enabled = 1
" silent !mkdir -p     ~/.vim/cache/backup >/dev/null 2>&1
" silent !mkdir -p     ~/.vim/cache/undo >/dev/null 2>&1

"FUXME: Use NeoBundle's lazy loading mechanism to ensure such plugins are only
"loaded on first loading files of corresponding filetype.
"NeoBundleLazy '', {'type' : 'txt'}      " syntax check Vimscript (namely, this file)

"FUXME: Delete unwanted schemes!
"NeoBundle '29decibel/codeschool-vim-theme'       " 3/5
"NeoBundle 'abra/obsidian2'                       " 0/5
"NeoBundle 'altercation/vim-colors-solarized'     " 2/5
"NeoBundle 'dsolstad/vim-wombat256i'              " 4/5
"" desert                                         " 2/5
"NeoBundle 'vim-scripts/moria'                    " 0/5
"NeoBundle 'vim-scripts/oceandeep'                " 4/5
"NeoBundle 'vim-scripts/peaksea'                  " 3/5

" * Concoct a new Python- or Ruby-enabled "confign" framework with
"   corresponding exheres, git, and http interface. This framework provides
"   configuration files for popular command-line tools: e.g., "ncmpcpp",
"   "vim". Interestingly, it should also provide configuration file variants
"   corresponding to "confign" configuration settings. For example, enabling
"   "dvorak: true" in "~/.confign" should implicitly provide configuration
"   files having Dvorak-centric key bindings.

"FUXME: Old unwanted spaces code. Great, but largely made redundant by
""listchars".
" Create highlight group "UnwantedWhitespace".
"highlight UnwantedWhitespace ctermbg=red guibg=red

" Highlight:
"
" * Trailing whitespace.
" * Spaces preceding tabs.
" * Tabs not at the start of lines.
"autocmd BufWinEnter * match UnwantedWhitespace /\s\+$\| \+\ze\t/
"autocmd BufWinEnter * match UnwantedWhitespace /\s\+$\| \+\ze\t\|[^\t]\zs\t\+/
"autocmd BufWinEnter * match UnwantedWhitespace /\s\+$/

" Highlight such whitespace except when typing at the end of lines.
"autocmd InsertEnter * match UnwantedWhitespace /\s\+\%#\@<!$/
"autocmd InsertLeave * match UnwantedWhitespace /\s\+$/
"autocmd BufWinLeave * call clearmatches()

" ....................{ COMMANDS                           }....................
" Define a new command "cp{motion}":
"
" Change paste, a motion-aware mapping replacing the string matching the passed
" motion with register "" (i.e., the previously yanked string). This function
" lifted with gratitude from user "ostler.c" at:
" http://stackoverflow.com/questions/2471175/vim-replace-word-with-contents-of-paste-buffer
"nmap <silent> cp :set opfunc=ChangePaste<CR>g@ function! ChangePaste(type, ...)
"silent exe "normal! `[v`]\"_c" silent exe "normal! p" endfunction
"
" Note: replace "S", below, by your desired indentation level. I prefer 2.
" Also,

" ....................{ PROGRAMS ~ mutt                    }....................
" Limit Mutt-composed e-mail to 72 characters per line, so as to conform to
" industrial practice.
"autocmd BufRead ~/tmp/mutt-* set tw=72 insertmode nonumber spell

"FUXME: Actually, Janus is probably not the best of ideas for power users.
"It's principally intended to bring new users up to speed, which we (arguably)
"are not.
" * Install Janus before *ANYTHING ELSE.* This is basically the equivalent of
"   Zeshy for vim, to a certain extent. It sets up Vim with sensible plugins
"   and default settings, and looks *VERY* full-featured. See:
"   https://github.com/carlhuda/janus

"FUXME: ??? Looks like we're mapping ",ft" to global search and replace
"of...what?
"map ,ft :%s/ / /g<CR> "

" --------------------( COPYRIGHT AND LICENSE              )--------------------
" The information below applies to everything in this distribution,
" except where noted.
"
" Copyright 2010-2013 by Cecil Curry.
"
"   http://www.raiazome.com
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program. If not, see <http://www.gnu.org/licenses/>.
