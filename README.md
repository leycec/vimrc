leycec/vimrc
===========

**Welcome to [leycec](https://github.com/leycec)'s `vimrc`.** Herein lie buried many things which if read with patience may show the strange meaning of maintaining well-structured and -commented Vim dotfiles.[*](http://genius.com/Web-du-bois-the-souls-of-black-folk-the-forethought-annotated)

![image](https://cloud.githubusercontent.com/assets/217028/7790996/592554e8-0265-11e5-8874-4c82cb7b02ca.png)

It's *sorta* like that.

## Six-word Synopsis

[No installation](#autoinstallation). [dein laziness](#dein). [Neon lucidity](#aesthetics).

## Nebulous Synopsis

Amongst our weaponry are such diverse elements as: **autoinstallation**, the **IDE-in-a-CLI** (i.e., [INTP](http://www.intp.org/intprofile.html) Shangri La), **old school aesthetics**, and **gratuitous Vim snippetry**.[*](https://www.youtube.com/watch?v=Tym0MObFpTI)

### Autoinstallation
<a name="autoinstallation"></a>

Our dotfiles require the following hard dependencies:

* **Vim** >= **7.4.427** compiled with the following features:
  * `+signs`.
* **Git**. Any Git should do, but newer Git is a happy Git.

**That's it.**

Our dotfiles implicitly install all other dependencies in a platform-aware manner on the next Vim startup. *No* installation script needs to be manually run; *no* external software needs to be manually installed. It's cyborg-like wonder, replete with [uncanny valley](https://www.youtube.com/watch?v=CNdAIPoh8a4) handwaving.

If you use [`vcsh`](https://github.com/RichiH/vcsh) to manage dotfiles, installation reduces to a single command:

    $ vcsh clone https://github.com/leycec/vimrc.git

See the [installation instructions](#installation) below.

### IDE-in-a-CLI
<a name="dein"></a>

Our dotfiles feature a [dein](https://github.com/Shougo/dein.vim)-managed suite of plugins<sup>1</sup> optimizing Vim into a command-line IDE. For efficiency, most plugins are loaded lazily (just-in-time) rather than at startup (all-at-once). For simplicity, *all* plugins including dein itself are automatically installed on the next Vim startup.

<sup>1. Bundles are third-party Vim plugins managed by a [Pathogen](https://github.com/tpope/vim-pathogen)-like... third-party Vim plugin. Typically hosted on Github, as Odin intended.</sup>

Prominent plugins include:

* [Asynchronous Lint Engine](https://github.com/w0rp/ale), providing real-time syntax checking. (No further configuration required. *Usually.*)
* [python-mode](https://github.com/klen/python-mode), providing [PyCharm](https://en.wikipedia.org/wiki/PyCharm)-like Python intelligence via the external code analysis library [rope](https://github.com/python-rope/rope).
* [Unite](https://github.com/Shougo/unite.vim), aggregating buffer, file, and register navigation and most-recently-used (MRU) recall of buffers, files, and registers. (*Currently disabled,* because we adamantly suck.)
* [Tim Pope](https://github.com/tpope)-fueled usability improvements, including:
  * [vim-fugitive](https://github.com/tpope/vim-fugitive), wrapping Git with Vim-augmented facilities for interactive diffing, grepping, logging, staging, and blaming (our favorite part!).
  * [vim-unimpaired](https://github.com/tpope/vim-unimpaired), adding `[`- and `]`-prefixed mnemonics for syntax-aware metamovements. It's as hot as it sounds.

### Aesthetics
<a name="aesthetics"></a>

Our dotfiles embrace such commendable art movements as: the 8-bit era, post-modernist minimalism, and [brutalism](http://fuckyeahbrutalism.tumblr.com). Adopt a [full-screen 256-color terminal](http://software.schmorp.de/pkg/rxvt-unicode.html) near you and bask in debatable ANSI glory.

* [vim-lucius](https://github.com/jonathanfilip/vim-lucius), a multi-paradigmal color scheme emphasizing low-contrast light-on-dark readability. Feast thine eyes on the lucious rapture!

![image](https://camo.githubusercontent.com/4cadf11a79898ac6ced753197ae5071bc6879aed/687474703a2f2f692e696d6775722e636f6d2f4c735a62462e706e67)

* [vim-airline](https://github.com/bling/vim-airline), a pure-VimL statusline theme emphasizing efficiency, extensibility, and monochromatic eroticism. ("It's the three E's, kids!") For portability, [Powerline-patched fonts](https://github.com/powerline/fonts) are neither required *nor* currently used. The animated GIF below is a seductive lie.

![image](https://github.com/bling/vim-airline/wiki/screenshots/demo.gif)

### Vim Snippetry

Our dotfiles promote the inscrutable art of Vim snippetry. For your [copypasta](https://www.reddit.com/r/copypasta) perusal, *every* block of *every* VimL in *every* dotfile in this repository has been scrupulously structured, commented, and contemplated. Usually at the most neckbeardly hour of the night.

**"Snippets galore!"**, we snort.

## Installation
<a name="installation"></a>

Dotfiles are a gritty business. Hand me my CLI shovel.

### vcsh (Recommended)

Our dotfiles are preferably installed via [`vcsh`](https://github.com/RichiH/vcsh), a Git-centric dotfile manager leveraging [internal Git cleverness](http://git-scm.com/book/en/v2/Git-Internals-Environment-Variables) rather than filesystem-level symlinks. (You *know* this to be a good thing.)

* **Install `vcsh`.** Specifically, under:
  * **Gentoo**-based Linux distros (e.g., **Calculate**):

            $ sudo emerge vcsh

  * **Debian**-based Linux distros (e.g., **Ubuntu**):

            $ sudo apt-get install vcsh

  * Platforms providing no `vcsh` package (e.g., **Cygwin**):

            $ git clone https://github.com/RichiH/vcsh.git && cd ~/vcsh && sudo make install

* **Move aside any existing dotfiles.** Renaming an existing `~/.vimrc` file to `~/.vimrc.local` ensures that _your_ dotfile will be sourced by _our_ dotfiles on Vim startup.

        $ mv ~/.vim{,.old}
        $ mv ~/.vimrc{,.local}

* **Install our dotfiles.**

        $ vcsh clone https://github.com/leycec/vimrc.git

* (_Optional_) For fellow Github developers:
  * **Enter the cloned repository.**

            $ vcsh enter vimrc

  * **Track the `github` branch**, storing front-facing Github documentation (including the current file).

            $ git fetch

  * **Install a Git `post-commit` hook**, synchronizing the `master` and `github` branches on every commit to the former.

            $ ln -s $HOME/.githook.d/vimrc.post-commit $GIT_DIR/hooks/post-commit

  * **Leave the cloned repository.**

            $ exit

You're done. Praise be to open-source Valhalla.

## Organization

Our dotfiles are internally structured as follows:

Path(s) | Purpose
:------ | :------
`.vimrc` | **Our dotfile.** A single line of uncommented code iteratively sourcing all Vim scripts under `.vim/conf.d` in lexicographic order.
`.vimrc.local` | **Your dotfile.** To avoid merge conflicts on repository updates, user-specific Vim settings should be segregated to this dotfile. Our dotfiles source this dotfile as their last action at Vim startup (i.e., immediately *before* returning control to Vim).
`.vim/` | **Our dotfile directory.** This is where the circus magic happens.
`.vim/conf.d/` | **Our main dotfile subdirectory.** Each file in this directory is a Vim script with basename matching `\d\d-[a-z]\.vim`. Since our `.vimrc` sources all scripts in this directory in lexicographic order, the two-digit numbers prefixing such basenames define the order such scripts are sourced in at Vim startup.
`.vim/cache/` | **Your temporary files.** This directory and all subdirectories thereof are implicitly (re)created as needed at Vim startup. For safety and/or security, *any* file or subdirectory in this directory may be safely removed at *any* time. Removing directories probably requires a Vim restart to restore depleted sanity.
`.vim/cache/backup/` | **Backup of previously edited files.** Each file in this directory persists the prior contents of the corresponding file (i.e., contents of the Vim buffer at the second-to-last write of that file).
`.vim/cache/swap/` | **Backup of currently edited files.** Each file in this directory *effectively* persists the current contents of the corresponding file *before* such file is officially written to disk (e.g., with `:w`). Such file will be restored at the user's prompting the next time that file is opened *after* a Vim session with that file opened crashed.
`.vim/cache/undo/` | **Undo trees for edited files.** Each file in this directory persists the undo tree of the corresponding file (i.e., directed acyclic graph (DAG) of all changes to such file). Such tree will be implicitly restored the next time that file is opened, thereby preserving undo history in a file-specific manner across Vim sessions.
`.vim/dein/` | **dein-specific subdirectory.** All dein-managed plugins are isolated to the two subdirectories of this subdirectory.
`.vim/dein/.cache/` | **dein's target cache.** For efficiency, the contents of all dein-managed plugins are centralized into this subdirectory.
`.vim/dein/repos/` | **dein's source plugins.** All dein-managed plugins are cloned from their remote repositories (typically, GitHub-hosted) into this subdirectory *before* being cached into dein's target cache.
`.gitignore.d/vcsh` | **`vcsh`-specific `.gitignore` file**. Probably only of interest to fellow `vcsh` users.
`.githooks/github-post-commit` | **Sample `post-commit` Git hook.** Synchronizes this repository's `master` and `github` branches. Probably only of interest to fellow `vcsh` users attempting to replicate our Github-based workflow.

## See Also

Actually, you ~~probably~~ really, *really* don't want to fork our dotfiles. While well-intended, they haven't yet metastasized into a general-purpose configuration likely to satisfy the greasy gamut of humanity. For those lacking dotfiles of their own, consider appropriating (in no meaningful order):

* [amix](https://github.com/amix)'s [vimrc](https://github.com/amix/vimrc). It's penultimate.
* [nvie](https://github.com/nvie)'s [vimrc](https://github.com/nvie/vimrc). It's *lots* of love.
* [tony](https://github.com/tony)'s [vimrc](https://github.com/tony/vim-config). It's a plugin of newness.

## License

All dotfiles are [permissively licensed](https://github.com/leycec/vimrc/blob/github/LICENSE) under the community-friendly [BSD 2-clause license](https://opensource.org/licenses/BSD-2-Clause).
