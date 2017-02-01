" --------------------( LICENSE                            )--------------------
" Copyright 2015-2017 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Vi[M], now with more IDE-osity. Whenever Vimscript questions arise, see:
"
" * "Learn Vimscript the Hard Way."
"   http://learnvimscriptthehardway.stevelosh.com
"
" Don't believe the title. This is absolutely the best book on Vimscript. It's
" concise; it's free; it's jocular. There is no better nor shall e'er be.
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
" ignored by Vim by default and hence specific to this custom dotfile.
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
