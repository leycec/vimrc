" --------------------( LICENSE                            )--------------------
" Copyright 2015-2017 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" dein configuration, defining the set of all dein-managed third-party
" Github-hosted plugins to be used.

"FIXME: Install https://github.com/airblade/vim-gitgutter, an utterly awesome
"plugin augmenting the gutter in an airline-aware manner with discrete "+" and
""-" symbols signifying changes versus the current branch HEAD. It also comes
"with a number of really awesome key bindings for navigating changes. Yeah!
"FIXME: Install https://github.com/mhinz/vim-signify, an alternative to
"gitgutter generally applicable to *ALL* VCSs. Do we want both? Simply, *YES*.
"gitgutter is more feature-full and hence preferable for git, thus relegating
"signify as a backup applicable to all other VCSs. Naturally, we would then need
"to conditionally disable signify for git buffers. Certainly feasible.

"FIXME: Unite integration should be substantially improved. The best
"introduction to Unite as of this writing is probably the following repo readme:
"    https://github.com/joedicastro/dotfiles/tree/master/vim
"After integrating Unite, excise airline's tagbar, which Unite (of course) also
"offers a facsimile of. "One plugin to unplugin them all!"
"FIXME: Refactor according to Shougo's ".vimrc", implementing (among other tasty
"things) a cache optimizing loading of dein dependencies on startup:
"
"    https://github.com/Shougo/shougo-s-github/blob/master/vim/vimrc
"    https://github.com/Shougo/shougo-s-github/blob/master/vim/rc/dein.toml
"
"Note the latter URL. Pretty crazy stuff. Shougo has implemented support for
"specifying your set of dein plugins as a single TOML (!) file rather than
"as one or more dein*() calls in vimL. (Although "readable," I happily
"prefer YAML.) While I can't imagine that we would want to migrate to this
"format, I should nonetheless note that the above TOML file now constitutes the
"definitive resource for lazy loading of new plugins. Awesome!
"FIXME: Physically delete unused plugins. Is there some means of instructing
"dein to print a list of all currently unused plugins? Hmm; yesss,
"dein does appear to provide an automated cleaning command:
":deinClean(). Let us use it!

" ....................{ INSTALL                            }....................
"FIXME: Most URLs below are artifacts from NeoBundle and hence invalid. *sigh*

" Common startup-related commands include:
"     :scriptnames      " list the absolute paths of all current startup scripts
"
" The dein plugin manager must be configured *BEFORE* dein-managed
" plugins -- which, in practice, means "bloody early in Vim startup." Common
" dein commands include:
"     call dein#install()  " install all configured plugins
"     call dein#update()   " update all installed plugins
"     :h dein              " peruse documentation
"
" For nonstandard Vim plugins requiring post-installation "intervention" (e.g.,
" "neocomplcache", "unite", "vimproc", "vimshell"), see official recipes (i.e.,
" Vim configuration snippets) at the following URLs:
"     https://github.com/Shougo/dein-vim-recipes
"     https://github.com/Shougo/dein-vim-recipes/tree/master/recipes
"
" While these recipes could be preloaded on Vim startup, doing so would probably
" violate lazy loading and hence unnecessarily increase startup time. That said:
"
"     " Leverage official Neoplugin recipes for popular plugins, if available.
"     dein 'Shougo/dein-vim-recipes', {'force' : 1}

" If dein is *NOT* installed, do so before doing anything else. dein
" is the fulcrum on which the remainder of this configuration rests.
if !isdirectory(g:our_dein_dir)
    echo "Installing dein...\n"
    execute
      \ 'silent !git clone https://github.com/Shougo/dein.vim ' .
      \ shellescape(g:our_dein_dir)
endif

" When starting but *NOT* reloading Vim...
if has('vim_starting')
    " Disable Vi-specific backwards compatibility. It's all Vim, all the time!
    if &compatible
        set nocompatible
    endif

    " Add dein to Vim's PATH.
    call AddRuntimePath(g:our_dein_dir)
endif

" ....................{ OPTIONS                            }....................
" Number of seconds after which to timeout plugin installation and upgrades.
" Since the default is insufficient for installing large plugins on slow
" connections, slightly increase such default.
let g:dein#install_process_timeout = 120

" ....................{ CONFIGURE                          }....................
" If dein's cache is either:
"
" * Stale (i.e., desynchronized from either current plugins or the plugin
"   configuration defined below).
" * Non-existent (e.g., due to this being a fresh installation of dein).
" * Invalid, for whatever edge-case reason.
"
" !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
" WARNING: To reduce startup speed, dein does *NOT* automatically synchronize
" the contents of the source "~/.vim/dein/repos" directory with the target
" "~/.vim/dein/.cache" directory. Instead, users *MUST* manually run the
" following Ex command on modifying the contents of the former:
"
"     call dein#recache_runtimepath()
"
" Yes, this sucks. No, there's nothing we can do about it. Yes, that sucks, too.
" !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

"FIXME: Unconvinced this is actually working. So much for efficiency. *sigh*
" if dein#load_state(g:our_plugin_dir)
    " Initialize dein, installing new plugins to and loading installed plugins
    " from the plugin subdirectory. Since dein adopts the whitelist approach
    " to plugin management, plugins *NOT* explicitly passed to dein#add() will
    " be disabled and hence *NOT* loaded.
    call dein#begin(g:our_plugin_dir)

    " ..................{ CORE                               }..................
    " Install dein with dein itself, completing the self-referential loop.
    call dein#add('Shougo/dein.vim')

    " ..................{ NON-LAZY ~ theme                   }..................
    "FIXME: I'm not entirely fond of either the comment or documentation colors.
    "Contemplate corrections.

    " Colour theme.
    call dein#add('jonathanfilip/vim-lucius')

    " Statusline theme.
    call dein#add('vim-airline/vim-airline')
    call dein#add('vim-airline/vim-airline-themes')

    " ..................{ NON-LAZY ~ vcs                     }..................
    " By definition, VCS wrappers *CANNOT* be loaded lazily -- despite the abundance
    " of online ".vimrc" examples erroneously suggesting they can. Since VCS wrapper
    " hooks *MUST* be run on buffer switches to detect whether that buffer is under
    " VCS control, VCS wrappers *MUST* be sourced before such switches. Then since
    " the first file to be opened constitutes a buffer switch *AND* since at least
    " one file is (typically) always open, VCS wrappers *MUST* be non-lazily sourced
    " on every Vim startup.
    "
    " Technically, this requirement is somewhat circumventable by defining
    " on_post_hook() hooks for the plugins installing such VCS wrappers that
    " explicitly call such VCS wrapper detection hooks. However:
    "
    " * Such detection hooks are often privatized to script-local functions. While
    "   such privacy is trivially breakable (and our dotfiles define utility
    "   functions for doing just that), the resulting logic depends on script
    "   internals *NOT* intended for public use and is hence liable to break without
    "   public notice.
    " * Such circumventions prevent display of VCS metadata in the Vim UI (e.g., the
    "   name of the current VCS branch in a statusline section).
    "
    " The costs are considerably higher than the negligible efficiency gains.

    " Git wrapper.
    call dein#add('tpope/vim-fugitive')

    " Mercurial wrapper.
    call dein#add('ludovicchabant/vim-lawrencium')

    " ..................{ LAZY ~ dependencies                }..................
    " Pure dependencies (i.e., plugins only dependencies of other plugins) are
    " lazily loadable without autoload specifications. Which is a good thing.
    "
    " Note that *ALL* plugins below must provide a directory structure
    " containing one or more of the following subdirectories:
    "
    " * "autoload/", functions autoloaded but *NOT* evaluated at Vim startup.
    " * "ftdetect/", autocommands detecting and setting plugin-specific
    "   filetypes unconditionally evaluated at Vim startup.
    " * "plugin/", arbitrary code unconditionally evaluated at Vim startup.
    "
    " Dein automatically inspects each plugin's substructure at cache
    " regeneration time to intelligently determine whether a plugin is lazily
    " loadable or not. For both efficiency and explicitness (e.g., to ensure
    " non-fatal warnings on attempting to lazy-load non-lazy-loadable plugins),
    " *ALL* plugins below should nonetheless be explicitly declared to be lazy.
    "
    " For further details on plugin substructure, see:
    "     http://learnvimscriptthehardway.stevelosh.com/chapters/42.html

    " Vertically align table-like text.
    call dein#add('godlygeek/tabular', {'lazy' : 1})

    " Low-level asynchronous Vim support.
    call dein#add('Shougo/vimproc.vim', {
      \ 'hook_post_update': "
      \ if dein#util#_is_windows()\n
      \     let cmd = 'tools\\update-dll-mingw'\n
      \ elseif dein#util#_is_cygwin()\n
      \     let cmd = 'make -f make_cygwin.mak'\n
      \ elseif executable('gmake')\n
      \     let cmd = 'gmake'\n
      \ else\n
      \     let cmd = 'make'\n
      \ endif\n
      \ let g:dein#plugin.build = cmd\n
      \ "})

    " Arbitrary information harvester.
    call dein#add('Shougo/unite.vim', {
      \ 'lazy' : 1,
      \ 'on_cmd': ['Unite', 'UniteResume'],
      \ 'hook_post_source': '
      \ " Match "fuzzily," effectively inserting the nongreedy globbing operator\n
      \ " "*?" between each character of the search pattern (e.g., searching for\n
      \ " "vvrc" in a unite buffer matches both "~/.vim/vimrc" and\n
      \ " "~/.vim/plugin/vundle/startup/rc.vim").\n
      \ call unite#filters#matcher_default#use(["matcher_fuzzy"])\n
      \ \n
      \ " Sort unite matches by descending rank.\n
      \ call unite#filters#sorter_default#use(["sorter_rank"])\n
      \ \n
      \ " Directory to which unite caches metadata.\n
      \ let g:unite_data_directory = g:our_cache_dir . "/unite"\n
      \ \n
      \ " Open unite buffers in Insert Mode by default.\n
      \ let g:unite_enable_start_insert = 1\n
      \ \n
      \ " String prefixing the unite input prompt.\n
      \ let g:unite_prompt = "» "\n
      \ \n
      \ " Enable unite source "unite-source-history/yank", permitting\n
      \ " exploration of yank history (e.g., via "yankring" or "yankstack").\n
      \ let g:unite_source_history_yank_enable = 1\n
      \ '})
      " \ 'depends': 'Shougo/vimproc',

    " easytags dependency.
    "call dein#add('xolox/vim-misc')

    " ....................{ LAZY ~ filetype                    }....................
    " CSS. Since the CSS plugin provided out-of-the-box by Vim lacks support for
    " most CSS3-specific syntactic constructs, external plugins are preferred.
    call dein#add('hail2u/vim-css3-syntax', {'on_ft': 'css'})

    " Markdown. There exist a variety of Markdown plugins, including:
    "
    " * "gabrielelana/vim-markdown", implementing GitHub-flavoured Markdown (GFMD),
    "   my preferred Markdown flavour. Frequently updated and fast on large buffers.
    " * "plasticboy/vim-markdown", implementing a generic flavour of Markdown.
    "   Frequently updated but slow on large buffers.
    " * "tpope/vim-markdown", doubling as Vim's default syntax highlighting plugin
    "   for Markdown. Infrequently updated, minimalist, and painfully generic.
    call dein#add('gabrielelana/vim-markdown', {
      \ 'on_ft': ['markdown', 'mkd'],
      \ })
      " \ 'depends': 'godlygeek/tabular',
    " call dein#add('gabrielelana/vim-markdown')

    " Python.
    call dein#add('klen/python-mode', {'on_ft': 'python'})

    " Zeshy.
    call dein#add('leycec/vim-zeshy', {'on_ft': 'zeshy'})

    " ..................{ LAZY ~ key                         }..................
    " Bind <gc-> (e.g., <gcc>) to perform buffer commenting and uncommenting.
    call dein#add('tomtom/tcomment_vim', {
      \ 'on_map': {'nx': ['gc', 'g<', 'g>', '<C-_>', '<Leader>_']},
      \ })

    " Bind <[> and <]> to syntax-aware metamovement. Specifically, bind:
    "
    " * <[n> to jump to the prior merge conflict if any.
    " * <]n> to jump to the next merge conflict if any.
    call dein#add('tpope/vim-unimpaired', {'on_map': {'nx': ['[', ']']}})

    " Improve <.> to support repeating of plugin-specaific key bindings.
    call dein#add('tpope/vim-repeat.git', {'on_map': {'n': '.'}})

    "FIXME: All of the following should probably be loaded lazily. It's unclear,
    "however, what the most efficient means of doing so should be.

    " EnchantedVim dependency, loaded non-lazily only as EnchantedVim is.
    call dein#add('coot/CRDispatcher.git')

    " Coerce <Enter> to inject '\v' magic on search-and-replacements.
    call dein#add('coot/EnchantedVim.git')
    " call dein#add('coot/EnchantedVim.git', {'depends': 'coot/CRDispatcher.git'})

    " ..................{ LAZY ~ filetype : rst              }..................
    " reStructuredText (reST).
    call dein#add('Rykka/riv.vim', {'on_ft': 'rst'})

    " If the external "instantRst" command is installed, the external "instant_rst"
    " Python package is assumed to also be installed, in which case the "InstantRst"
    " plugin by the same author integrating with the "riv.vim" plugin installed
    " above is both safely installable *AND* usable.
    if executable('instantRst')
        call dein#add('Rykka/InstantRst', {'on_ft': 'rst'})

    "FIXME: While warning the user of this condition would be generally useful, Vim
    "appears to provide no means of doing so without requiring the user to manually
    "press a key on *EVERY* Vim startup after displaying this warning. This warning
    "is currently disabled until a less intrusive warning mechanism is discovered.

    " Else, "InstantRst" is *NOT* safely installable. Warn the user appropriately.
    " else
    "     echomsg '"instantRst" command not found; reStructuredText buffers not previewable.'
    endif

    " ..................{ LAZY ~ syntax                      }..................
    " CSS-specific syntax highlighting.
    call dein#add('ap/vim-css-color', {'on_ft': ['css', 'scss', 'sass']})

    "FIXME: Fantastic plugin for reformatting. There's only one issue: we only want
    "to make the ":Autoformat" command available. Unfortunately, this plugin also
    "forcefully overrides Vim's builtin "gq" functionality with its filetype-
    "specific logic. This works tolerably for some filetypes, but utterly fails on
    "others. In particular, "autopep8" for Python refuses to wrap long comments
    "appropriately. Consequently, this plugin must be temporarily enabled *ONLY* for
    "the duration of edits requiring the ":Autoformat" command. *sigh*

    " Filetype-aware syntax reformatting, augmenting "gq" with intelligent
    " reformatting specific to language standards. This plugin inspects the external
    " environment for commands in the current ${PATH} and hence typically requires
    " *NO* manual configuration. Such commands include:
    "
    " * For filetype "python", command "autopep8".
    " call dein#add('Chiel92/vim-autoformat', {
    "   \ 'autoload': { 'filetypes': ['python'] }
    "   \ }

    " If Vim supports asynchronous job control, enable asynchronous syntax
    " checking via the Asynchronous Linting Engine (ALE). If Vim does *NOT*
    " support asynchronous job control, we avoid enabling any syntax checking.
    " Why? Because synchronous syntax checking is overly obtrusive and feeble,
    " given the ubiquity of modern Vim support for asynchronous job control.
    "
    " The dein-compatible ALE plugin supplants our prior use of the
    " dein-incompatible "watchdogs" plugin, which tragically failed to scale.
    if g:our_is_job_async
        call dein#add('w0rp/ale', {
          \ 'on_ft': [
          \     'c', 'cpp', 'd',
          \     'css', 'sass', 'scss',
          \     'javascript', 'coffee', 'typescript',
          \     'java', 'scala',
          \     'go', 'rust',
          \     'haml',
          \     'haskell',
          \     'lua', 'python', 'perl', 'php', 'ruby',
          \     'sh', 'zsh',
          \     'vim',
          \ ],
          \ 'hook_post_source': '
          \ " Enable statusline integration with airline.\n
          \ let g:airline#extensions#ale#enabled = 1\n
          \ '})
    endif

    "FIXME: Currently disabled. One of the plugins mentioned below leverages
    ""vimparser"; the other does not. Since "vimparser" is awesome, enable whichever
    "of the two leverages this plugin.

    " Filetype-specific syntax checking.
    "
    " Vimscript. (There exists another Vimscript checker of the same name at
    " https://github.com/syngan/vim-vimlint, which appears to *NOT* play nicely
    " with Syntastic. Hence, prefer this.)
    " call dein#add('dbakker/vim-lint', {
    "   \ 'autoload': { 'filetypes': ['vim'] }
    "   \ }

    " ..................{ LAZY ~ vcs                         }..................
    " Git log wrapper. While otherwise excellent, "vim-fugitive" particularly
    " lacks in this department.
    call dein#add('kablamo/vim-git-log', {'on_cmd': 'GitLog'})

    "FIXME: Currently disabled, due to "vimgitlog" being basically broken. That
    "said, it's the only currently maintained Vim plugin purporting to do this.

    " Git log wrapper. While otherwise excellent, "vim-fugitive" particularly
    " lacks in this department.
    " call dein#add('PAntoine/vimgitlog', {
    "   \ 'autoload': {
    "   \     'functions': [ 'GITLOG_ToggleWindows', 'GITLOG_FlipWindows',]
    "   \ }}

    " ..................{ LAZY ~ rest                        }..................
    " Buffer undo/redo.
    "
    " Navigate the undo history tree.
    call dein#add('mbbill/undotree', {'on_cmd': 'UndotreeToggle'})

    " File exploring.
    call dein#add('Shougo/vimfiler', {
      \ 'on_cmd': ['VimFiler', 'VimFilerExplorer'],
      \ 'hook_post_source': '
      \ " Set vimfiler as the default file explorer.\n
      \ let g:vimfiler_as_default_explorer = 1\n
      \ '})
      " \ 'depends': 'Shougo/unite.vim',
      " \ 'on_cmd': ['VimFiler', 'VimFilerExplorer'],
      " \ })

    "FIXME: Temporarily disabled. We don't currently leverage tags functionality
    "terribly much, and there appear to be conflicts with git-based Universal Ctags.
    " Project tags.
    " call dein#add('xolox/vim-easytags', {
    "   \ 'depends': 'xolox/vim-misc',
    "   \ 'autoload': { 'filetypes': ['zeshy'] },
    "   \ }

    "FIXME: Unconvinced I require a grepping plugin. If I ever do, however, this is
    "undoubtedly the one to uncomment. State of the art.
    " File grepping.
    "call dein#add('rking/ag.vim', { 'autoload': {
    "            \ 'commands': [{'name': 'Ag', 'complete': 'file'}] }}

    " Finalize dein's in-memory configuration.
    call dein#end()

    "FIXME: Unconvinced this is actually working. So much for efficiency. *sigh*
    " Finalize dein's on-disk cache.
    call dein#save_state()
" endif

" ....................{ STOP                               }....................
" If one or more plugins are *NOT* currently installed, do so.
if dein#check_install()
    echo "Installing dein plugins...\n"
    call dein#install()
endif

" Asynchronously update all currently dein-installed plugins on a fixed
" schedule. Available schedules include:
"
" * auto_dein#update_daily(), updating plugins once per day.
" * auto_dein#update_every_3days(), updating plugins once every three days.
" * auto_dein#update_weekly(), updating plugins once per week.
" * auto_dein#update_every_30days(), updating plugins once per month.
" augroup Autodein
"     autocmd!
"     autocmd VimEnter * call auto_dein#update_weekly()
" augroup END

" ....................{ FILETYPES                          }....................
" Enable the following four core features (related to filetypes) *AFTER*
" completing dein configuration but *BEFORE* subsequent functionality
" requiring such features. (Attempting to enable these features *BEFORE*
" beginning dein configuration erroneously overwrites the "formatoptions"
" option with garbage. Presumably, other horrible things occur as well.)
"
" * Filetype detection. On opening new buffers, Vim attempts to deduce the
"   filetype for such buffer from the filename associated with such buffer (if
"   any) and/or shebang or modeline lines (if any) at the head of such buffer.
"   Vim uses filetypes for syntax highlighting and the two features below.
" * Filetype-dependent plugin files. Different filetypes are commonly associated
"   with different Vim options. So-called "filetype plugins" ensure these
"   options are set on opening buffers of these filetypes.
" * Filetype-dependent indentation files. Different filetypes are commonly
"   associated with different indentation rules. As with filetype plugins,
"   these files ensure these rules are set on opening buffers of this filetype.
"
" Do *NOT* attempt to enable support for filetype-dependent syntax highlighting
" files. Since doing so here disables this support, do so *AFTER* completing
" all dein-related tasks below.
filetype plugin indent on
