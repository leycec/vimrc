" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.

"FIXME: Refactor according to Shougo's ".vimrc", implementing (among other tasty
"things) a cache optimizing loading of NeoBundle dependencies on startup:
"
"    https://github.com/Shougo/shougo-s-github/blob/master/vim/vimrc
"    https://github.com/Shougo/shougo-s-github/blob/master/vim/rc/neobundle.toml
"
"Note the latter URL. Pretty crazy stuff. Shougo has implemented support for
"specifying your set of NeoBundle bundles as a single TOML (!) file rather than
"as one or more NeoBundle*() calls in vimL. (Although "readable," I happily
"prefer YAML.) While I can't imagine that we would want to migrate to this
"format, I should nonetheless note that the above TOML file now constitutes the
"definitive resource for lazy loading of new bundles. Awesome!
"FIXME: Physically delete unused bundles. Is there some means of instructing
"NeoBundle to print a list of all currently unused bundles? Hmm; yesss,
"NeoBundle does appear to provide an automated cleaning command:
":NeoBundleClean(). Let us use it!

" ....................{ START                              }....................
" Common startup-related commands include:
"     :scriptnames      " list the absolute paths of all current startup scripts

" When starting but *NOT* reloading Vim...
if has('vim_starting')
    " Disable Vi-specific backwards compatibility. It's all Vim, all the time.
    if &compatible
        set nocompatible
    endif

    " Add NeoBundle to Vim's plugin path.
    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" ....................{ START ~ neobundle                  }....................
" Configure the NeoBundle plugin manager *BEFORE* installed plugins -- which, in
" practice, means "early in Vim startup." Common commands include:
"     :NeoBundleList            " list configured bundles
"     :NeoBundleClean           " confirm removal of unused bundles
"     :NeoBundleUpdate          " update all installed bundles
"     :h neobundle              " peruse documentation
"
" To install configured plugins, either restart "vim" or interactively run:
"     :NeoBundleInstall         " or...
"     :Unite neobundle/install  " ...requires unite
"
" For nonstandard Vim plugins requiring post-installation "intervention" (e.g.,
" "neocomplcache", "unite", "vimproc", "vimshell"), see official recipes (i.e.,
" Vim configuration snippets) at the following URLs:
"     https://github.com/Shougo/neobundle-vim-recipes
"     https://github.com/Shougo/neobundle-vim-recipes/tree/master/recipes
"
" While such recipes could be preloaded on Vim startup, doing so would probably
" violate lazy loading and hence unnecessarily increase startup time. That said:
"
"     " Leverage official Neobundle recipes for popular plugins, if available.
"     NeoBundle 'Shougo/neobundle-vim-recipes', {'force' : 1}

" Initialize NeoBundle, installing new bundles to and loading installed bundles
" from the following subdirectory. Since NeoBundle adopts the whitelist approach
" to bundle management, bundles *NOT* explicitly passed to either NeoBundle() or
" NeoBundleLazy() below will be disabled and hence *NOT* loaded.
call neobundle#begin(expand('~/.vim/bundle/'))

" Number of seconds after which to timeout plugin installation and upgrades.
" Since the default is insufficient for installing large plugins on slow
" connections, slightly increase such timeout.
let g:neobundle#install_process_timeout = 120

" ....................{ CORE                               }....................
" Install NeoBundle updates with NeoBundle itself.
NeoBundleFetch 'Shougo/neobundle.vim'

"FIXME: Unfortunately broken as of the current date and unupdated since 2012.
" Auto-update NeoBundle bundles on a fixed schedule. (See below for config.)
" NeoBundle 'rhysd/auto-neobundle', {
"   \ 'depends': ['Shougo/unite.vim'],
"   \ }

" ....................{ NON-LAZY ~ key                     }....................
"FIXME: All of the following should probably be loaded lazily. Unfortunately,
"there appears to be no simple means (at the moment) of doing so on key events.

" Bind <[> and <]> to syntax-aware metamovement.
NeoBundle 'tpope/vim-unimpaired'

" Improve <.> to support repeating of plugin-specific key bindings.
NeoBundle 'tpope/vim-repeat.git'

" Coerce <Enter> to inject '\v' magic on search-and-replacements.
NeoBundle 'coot/EnchantedVim.git', {
  \ 'depends': ['coot/CRDispatcher.git'],
  \ }

" ....................{ NON-LAZY ~ theme : colour          }....................
"FIXME: I'm not entirely fond of either the comment or documentation colors.
"Contemplate corrections.

" Colour theme.
NeoBundle 'jonathanfilip/vim-lucius'

" ....................{ NON-LAZY ~ theme : statusline      }....................
" Statusline theme.
NeoBundle 'bling/vim-airline'

" ....................{ NON-LAZY ~ rest                    }....................
" Buffer commenting/uncommenting.
"
" While lazily loading tcomment would be preferable, such plugin defines core
" key bindings with nontrivial definitions on load. To avoid redefining such
" key bindings below, load tcomment "up front."
NeoBundle 'tomtom/tcomment_vim'

" ....................{ LAZY ~ dependencies                }....................
" Pure dependencies (i.e., plugins only dependencies of other plugins) are
" lazily loadable without autoload specifications. Which is a good thing.

" Highlight syntax errors in the current buffer.
NeoBundleLazy 'cohama/vim-hier'

" EnchantedVim dependency.
NeoBundleLazy 'coot/CRDispatcher.git'

" Display quickfix messages in the command line.
NeoBundleLazy 'dannyob/quickfixstatus'

" Integrate watchdogs with the statusline.
NeoBundleLazy 'KazuakiM/vim-qfstatusline'

" ASCII art-style animation renderer.
NeoBundleLazy 'osyo-manga/shabadou.vim'

" Low-level asynchronous Vim support, inspired by the official recipe at:
"     https://github.com/Shougo/neobundle-vim-recipes/blob/master/recipes/vimproc.vim.vimrecipe
NeoBundleLazy 'Shougo/vimproc', {
  \ 'build': {
  \     'windows': 'tools\\update-dll-mingw',
  \     'cygwin':  'make -f make_cygwin.mak',
  \     'mac':     'make -f make_mac.mak',
  \     'linux':   'make',
  \     'unix':    'gmake',
  \     }
  \ }

" Arbitrary information harvester.
NeoBundleLazy 'Shougo/unite.vim', {
  \ 'depends': ['Shougo/vimproc'],
  \ 'autoload': {'commands': ['Unite', 'UniteResume']}
  \ }

" High-level asynchronous Vim support, wrapping "vimproc".
NeoBundleLazy 'thinca/vim-quickrun', {
  \ 'depends': ['Shougo/vimproc'],
  \ }

" easytags dependency.
NeoBundleLazy 'xolox/vim-misc'

" ....................{ LAZY ~ fugitive                    }....................
" Tim Pope's infamous git plugin. The following lazy loading code was stripped
" directly from:
"     https://github.com/pgilad/vim-lazy-recipes/blob/master/tpope.vim-fugitive.vim
NeoBundleLazy 'tpope/vim-fugitive', {
  \ 'autoload': {
  \     'commands': [
  \         'Gcd', 'Gcommit', 'Gdiff', 'Ggrep', 'Git', 'Git!',
  \         'Glcd', 'Glog', 'Gstatus', 'Gwrite',
  \         ],
  \     },
  \ }

if neobundle#tap('vim-fugitive')
    function! neobundle#hooks.on_post_source(bundle)
        call fugitive#detect(expand('#:p'))
    endfunction
    call neobundle#untap()
endif

" ....................{ LAZY ~ filetype                    }....................
" Markdown.
NeoBundleLazy 'tpope/vim-markdown', {
  \ 'autoload': { 'filetypes': ['markdown', 'md'] }
  \ }

" Python.
NeoBundleLazy 'klen/python-mode', {
  \ 'autoload': { 'filetypes': 'python' }
  \ }

" ....................{ LAZY ~ syntax                      }....................
" CSS-specific syntax highlighting.
NeoBundleLazy 'ap/vim-css-color', {
  \ 'autoload': { 'filetypes': ['css', 'scss', 'sass'] }
  \ }

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
" NeoBundleLazy 'Chiel92/vim-autoformat', {
"   \ 'autoload': { 'filetypes': ['python'] }
"   \ }

" Asynchronous syntax checking. 'cohama/vim-hier' and 'dannyob/quickfixstatus'
" are technically only optional dependencies but nonetheless listed here to
" ensure loading of such bundles *BEFORE* watchdogs itself, in turn ensuring
" that watchdogs enables functionality depending on such modules.
NeoBundleLazy 'osyo-manga/vim-watchdogs', {
  \ 'depends': [
  \     'thinca/vim-quickrun', 'osyo-manga/shabadou.vim',
  \     'cohama/vim-hier', 'dannyob/quickfixstatus',
  \     'KazuakiM/vim-qfstatusline',
  \     ],
  \ 'filetypes': [
  \     'c', 'coffee', 'cpp', 'd', 'go', 'haml', 'java', 'javascript',
  \     'haskell', 'lua', 'python', 'perl', 'php',
  \     'ruby', 'sass', 'scala', 'scss', 'sh', 'typescript', 'vim', 'zsh',
  \     ],
  \ }

"FIXME: Currently disabled. One of the plugins mentioned below leverages
""vimparser"; the other does not. Since "vimparser" is awesome, enable whichever
"of the two leverages such plugin.

" Filetype-specific syntax checking.
"
" Vimscript. (There exists another Vimscript checker of the same name at
" https://github.com/syngan/vim-vimlint, which appears to *NOT* play nicely
" with Syntastic. Hence, prefer this.)
" NeoBundleLazy 'dbakker/vim-lint', {
"   \ 'autoload': { 'filetypes': ['vim'] }
"   \ }

" ....................{ LAZY ~ rest                        }....................
" Buffer undo/redo.
"
" Navigate the undo history tree.
NeoBundleLazy 'mbbill/undotree', {
  \ 'autoload': { 'commands': ['UndotreeToggle'] }
  \ }

"FIXME: O.K.; we'll need to fork https://github.com/neurogeek/gentoo-overlay,
"add a new "instant-markdown-d" ebuild, and file a pull request. Should be
"sweet! Uncomment 'suan/vim-instant-markdown' below after such ebuild is
"working.

" Filetype-specific browser previewing.
"
" Markdown. Note that "vim-instant-markdown" requires external dependencies,
" which are preferably installed via official package managers. Nonetheless, the
" build instructions remain for reference.
"NeoBundleLazy 'suan/vim-instant-markdown', {
"            \ 'autoload': { 'filetypes': ['markdown', 'md'] }}
"            \ 'build': {
"            \   'mac':  'sudo gem install pygments.rb; sudo gem install redcarpet; npm -g install instant-markdown-d ',
"            \   'unix': 'sudo gem install pygments.rb; sudo gem install redcarpet; sudo npm -g install instant-markdown-d ',
"            \ },

" File exploring.
NeoBundleLazy 'Shougo/vimfiler', {
  \ 'depends': 'Shougo/unite.vim',
  \ 'autoload': { 'commands': ['VimFiler', 'VimFilerExplorer'] },
  \ }

" Project tags.
NeoBundleLazy 'xolox/vim-easytags', {
  \ 'depends': 'xolox/vim-misc',
  \ 'autoload': { 'filetypes': ['zeshy'] },
  \ }

"FIXME: Unconvinced I require a grepping plugin. If I ever do, however, this is
"undoubtedly the one to uncomment. State of the art.
" File grepping.
"NeoBundleLazy 'rking/ag.vim', { 'autoload': {
"            \ 'commands': [{'name': 'Ag', 'complete': 'file'}] }}

" ....................{ STOP                               }....................
" Load all subdirectories of this directory as Vim plugins.
call neobundle#local(expand('~/vim'))

" Finalize NeoBundle configuration.
call neobundle#end()

" ....................{ FILETYPES                          }....................
" Enable the following four core features (related to filetypes) *AFTER*
" completing NeoBundle configuration but *BEFORE* subsequent functionality
" requiring such features. (Attempting to enable such features *BEFORE*
" beginning NeoBundle configuration erroneously overwrites the "formatoptions"
" option with garbage. Presumably, other horrible things occur as well.)
"
" * Filetype detection. On opening new buffers, Vim attempts to deduce the
"   filetype for such buffer from the filename associated with such buffer (if
"   any) and/or shebang or modeline lines (if any) at the head of such buffer.
"   Vim uses filetypes for syntax highlighting and the two features below.
" * Filetype-dependent plugin files. Different filetypes are commonly associated
"   with different Vim options. So-called "filetype plugins" ensure such options
"   are set on opening buffers of such filetype.
" * Filetype-dependent indentation files. Different filetypes are commonly
"   associated with different indentation rules. As with filetype plugins,
"   these files ensure such rules are set on opening buffers of such filetype.
"
" Do *NOT* attempt to enable support for filetype-dependent syntax highlighting
" files. Since doing so here disables such support, do so *AFTER* completing
" all NeoBundle-related tasks below.
filetype plugin indent on

" ....................{ UPDATING                           }....................
" Install uninstalled plugins on Vim startup. Since such function does *NOT*
" update installed plugins, consider calling :NeoBundleUpdate() on occasion.
NeoBundleCheck

" Asynchronously update all currently NeoBundle-installed bundles on a fixed
" schedule. Available schedules include:
"
" * auto_neobundle#update_daily(), updating bundles once per day.
" * auto_neobundle#update_every_3days(), updating bundles once every three days.
" * auto_neobundle#update_weekly(), updating bundles once per week.
" * auto_neobundle#update_every_30days(), updating bundles once per month.
" augroup AutoNeoBundle
"     autocmd!
"     autocmd VimEnter * call auto_neobundle#update_weekly()
" augroup END

" --------------------( WASTELANDS                         )--------------------
