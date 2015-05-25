leycec/vimrc
===========

**Welcome to [leycec](https://github.com/leycec)'s `vimrc`.** Herein lie buried many things which if read with patience may show the strange meaning of maintaining well-structured and -commented Vim dotfiles.[*](http://genius.com/Web-du-bois-the-souls-of-black-folk-the-forethought-annotated)

![image](https://cloud.githubusercontent.com/assets/217028/7790996/592554e8-0265-11e5-8874-4c82cb7b02ca.png)

It's *sorta* like that.

## Motivation

Amongst our weaponry are such diverse elements as: the **IDE-in-a-CLI**, **old school aesthetics**, and **gratuitous Vim snippetry**.[*](https://www.youtube.com/watch?v=Tym0MObFpTI)

### IDE-in-a-CLI

Our dotfiles feature a [NeoBundle](https://github.com/Shougo/neobundle.vim)-managed suite of bundles (third-party Vim plugins typically hosted on Github) optimizing Vim into a command-line IDE. For efficiency, most bundles are loaded lazily (just-in-time) rather than at startup (all-at-once). For simplicity, *all* bundles are automatically installed in a platform-specific manner on the first startup.

Prominent bundles include:

* [vim-watchdogs](https://github.com/osyo-manga/vim-watchdogs), providing real-time syntax checking. (No further configuration required. *Usually.*)
* [python-mode](https://github.com/klen/python-mode), providing [PyCharm](https://en.wikipedia.org/wiki/PyCharm)-like Python intelligence via the external code analysis library [rope](https://github.com/python-rope/rope).
* [Unite](https://github.com/Shougo/unite.vim), aggregating buffer, file, and register navigation and most-recently-used (MRU) recall of buffers, files, and registers. (*Currently disabled,* because we adamantly suck.)
* [Tim Pope](https://github.com/tpope)-fueled usability improvements, including:
  * [vim-fugitive](https://github.com/tpope/vim-fugitive), wrapping Git with Vim-augmented facilities for interactive diffing, grepping, logging, staging, and blaming (our favorite part!).
  * [vim-unimpaired](https://github.com/tpope/vim-unimpaired), adding `[`- and `]`-prefixed mnemonics for syntax-aware metamovements. It's as hot as it sounds.

### Old School Aesthetics

Our dotfiles embrace such commendable art movements as: the 8-bit era, post-modernist minimalism, and [brutalism](http://fuckyeahbrutalism.tumblr.com). Adopt a [full-screen 256-color terminal](http://software.schmorp.de/pkg/rxvt-unicode.html) near you and bask in debatable ANSI glory. 

* [vim-lucius](https://github.com/jonathanfilip/vim-lucius), a multi-paradigmal color scheme emphasizing low-contrast light-on-dark readability. Feast thine eyes on the lucious rapture!
 
![image](https://camo.githubusercontent.com/4cadf11a79898ac6ced753197ae5071bc6879aed/687474703a2f2f692e696d6775722e636f6d2f4c735a62462e706e67)

* [vim-airline](https://github.com/bling/vim-airline), a pure-VimL statusline theme emphasizing efficiency, extensibility, and astonishing displays of hedonistic eroticism. (Just kidding on that last one. *We think.*)

![image](https://github.com/bling/vim-airline/wiki/screenshots/demo.gif)

### Vim Snippetry

Our dotfiles promote the inscrutable art of Vim snippetry. For your [copypasta](https://www.reddit.com/r/copypasta) perusal, *every* block of *every* VimL in *every* dotfile in this repository has been scrupulously structured, commented, and contemplated. Usually at the most neckbeardly hour of the night.

Snippets galore, we say!

## Installation

Dotfiles are a gritty business. Hand me that CLI shovel.

### vcsh (Recommended)

Our dotfiles are preferably installed via [`vcsh`](https://github.com/RichiH/vcsh), a Git-centric dotfile manager cleverly leveraging [Git-specific environment variables](http://git-scm.com/book/en/v2/Git-Internals-Environment-Variables) rather than fragile symlinks. This is a good thing.

* Install `vcsh`.
  * Under Gentoo-based Linux distros:

        $ sudo emerge vcsh

  * Under Debian-based Linux distros (e.g., Ubuntu):

        $ sudo apt-get install vcsh

* Install `leycec/vimrc`.

        $ vcsh clone https://github.com/leycec/vimrc.git

You're done. **You can thank us later.**

## See Also

Actually, you ~~probably~~ really, *really* don't want to fork our dotfiles. While well-intended, they haven't yet metastasized into a general-purpose configuration likely to satisfy the greasy gamut of humanity. If you currently lack Vim dotfiles of your own, consider (in no meaningful order):

* [amix](https://github.com/amix)'s [vimrc](https://github.com/amix/vimrc). It's penultimate.
* [nvie](https://github.com/nvie)'s [vimrc](https://github.com/nvie/vimrc). It's *lots* of love.

## License

Our dotfiles are [licensed](https://github.com/leycec/vimrc/blob/github/LICENSE) under the [University of Illinois/NCSA Open Source License](https://en.wikipedia.org/wiki/University_of_Illinois/NCSA_Open_Source_License),
a hospitably lax license for the whole Vim family.
