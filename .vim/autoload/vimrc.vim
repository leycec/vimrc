scriptencoding utf-8
" --------------------( LICENSE                           )--------------------
" Copyright 2015-2020 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                          )--------------------
" Dotfile-specific autoloadable functions, providing custom functionality
" required either conditionally by certain code paths *OR* not at all and hence
" intended to be called manually by the user as "call "-prefixed Ex commands.
"
" By Vim mandate, all functions defined by this script *MUST* be prefixed by
" "vimrc#". In return, Vim sources this script and hence autoloads all such
" functions on the first call to any such function.
"
" --------------------( SNIPPETS                          )--------------------
" Note the following vimscript snippets, which are sufficiently succinct to
" *NOT* warrant full-blown functions:
"
" * Convert Microsoft (e.g., MS-DOS, Windows) to UNIX newlines. Either:
"   * Globally strip all "^M" control characters from the current buffer. Note,
"     however, that this only works for buffers whose newlines are *ALL*
"     unconditionally terminated by Microsoft newlines. For mixed-mode buffers
"     (i.e., buffers whose newlines are terminated by a heterogenous mixture of
"     both Microsoft and UNIX newlines), see the subsequent snippet:
"         :set ff=unix
"   * Globally strip all "^M" control characters from the current buffer. Note
"     that, unlike the prior snippet, this snippet universally applies to *ALL*
"     buffers – including mixed-mode buffers containing a mixture of both
"     Microsoft and UNIX newlines:
"         :%s/\r//g

" ....................{ TESTERS                           }....................
" vimrc#is_buffer_viewable() -> bool
"
" 1 if a view should be persisted for the current buffer or 0 otherwise.
function! vimrc#is_buffer_viewable() abort
    " Filename associated with this buffer.
    let l:filename = expand('%:p')

    " Persist no view for this buffer if...
    "
    " ...this buffer has no type.
    if &buftype != '' | return 0 | endif

    " ...this buffer is read-only.
    if &modifiable == 0 | return 0 | endif

    " ...this is a diff buffer.
    if &l:diff | return 0 | endif

    " ...this filename is "["- and "]"-delimited. (We have no idea what this
    " implies, but presumably it implies this buffer to require no view.)
    if expand('%') =~ '\[.*\]' | return 0 | endif

    " ...this file does *NOT* exist.
    if empty(glob(l:filename)) | return 0 | endif

    "FIXME: This simplistic logic fails to handle files residing in
    "subdirectories of this temporary directory.

    " ...this file resides in a temporary directory.
    if len($TEMP) && expand('%:p:h') == $TEMP | return 0 | endif
    if len($TMP ) && expand('%:p:h') == $TMP  | return 0 | endif

    " For each regular expression matching filenames to *NOT* persist views
    " for...
    for l:unviewable_filename_regex in g:our_unviewable_filename_regexes
        " If this buffer has such a filename, persist no view for this buffer.
        if l:filename =~ l:unviewable_filename_regex
            return 0
        endif
    endfor

    " Else, persist a view for this buffer.
    return 1
endfunction


" vimrc#is_option(option_name: str) -> bool
"
" 1 if a Vim option with the passed name both exists *AND* works (i.e.,
" behaves as expected) or 0 otherwise.
function! vimrc#is_option(option_name) abort
    " Without the preceding "+" sigil, the builtin exists() tester only tests
    " whether the passed option exists rather than whether that option both
    " exists *AND* works. Since non-working options are largely useless, we
    " enforce both conditions.
    return exists('+' . a:option_name)
endfunction

" ....................{ TESTERS ~ path                    }....................
" vimrc#is_path(pathname: str) -> bool
"
" 1 if a directory or file with the passed absolute or relative pathname
" (possibly prefixed by an optional "~/", expanding to the absolute dirname of
" the home directory for the current user) exists or 0 otherwise.
"
" This function was gratefully inspired by the following external source:
"
" * brianmearns's code snippet, published at:
"   https://stackoverflow.com/a/23496813/2809027
function! vimrc#is_path(pathname) abort
    return !empty(glob(a:pathname))  " ...pithy one-liners for great justice.
endfunction

" ....................{ GETTERS ~ script                  }....................
" vimrc#get_script_function(
"     script_filename: str, function_name: str) -> FunctionType
"
" Get the function with the passed name declared by the script with the passed
" absolute path.
"
" This function is principally intended to break the fake privacy provided by
" "s:". See GetScriptSID() for details.
"
" This function was gratefully lifted from the following external source:
"
" * Kanno Kanno's s:get_func() function, published at:
"   http://kannokanno.hatenablog.com/entry/20120720/1342733323
function! vimrc#get_script_function(script_filename, function_name) abort
    let l:sid = vimrc#get_script_sid(a:script_filename)
    return function("<SNR>" . l:sid . '_' . a:function_name)
endfunction


" vimrc#get_script_sid(script_filename: str) -> int
"
" Get the script ID (SID) that Vim assigned to the script with the passed
" absolute path. This function is principally intended to break the thin veneer
" of privacy provided by "s:", syntactic sugar prefixing function names which
" Vim internally mangles into "<SNR>${SID}_" (where "${SID}" is the SID of the
" script declaring such functions).
"
" This function was gratefully inspired by the following external source:
"
" * Yasuhiro Matsumoto's GetScriptID() function, published at:
"   http://mattn.kaoriya.net/software/vim/20090826003359.htm
function! vimrc#get_script_sid(script_filename) abort
    " Capture the contents of the buffer output by calling scriptnames() to a
    " function-local variable.
    redir => l:scriptnames_output
    silent! scriptnames
    redir END

    " If the passed filename is prefixed by the absolute path of the current
    " user's home directory, replace such prefix by "~". This permits such path
    " to be matched in such output, which does the same.
    let l:script_filename = substitute(
      \ a:script_filename, '^' . $HOME . '/', '~/', '')

    " Parse this output as follows:
    "
    " * Split this output on newlines. Vim guarantees each resulting line to be
    "   formatted as "${SID}: ${script_filename}", where:
    "   * The first listed script has SID 1.
    "   * Each successive script an SID one larger than the prior.
    " * Reduce each such line to its filename. SIDs are guaranteed to follow a
    "   simple pattern and hence ignorable for our purposes.
    " * Get one less than the line number of the script with the passed
    "   filename or -1 if such script has *NOT* been sourced yet.
    let l:script_line = index(
      \ map(
      \   split(l:scriptnames_output, "\n"),
      \   "substitute(v:val, '^[^:]*:\\s*\\(.*\\)$', '\\1', '')"
      \ ), l:script_filename)

    " If this script has *NOT* been sourced yet, print a non-fatal warning.
    if l:script_line == -1
        throw '"' . l:script_filename . '" not previously sourced.'
    endif

    " Return the line number of this script -- which, by Vim design, is
    " guaranteed to be this script's SID.
    return l:script_line + 1
endfunction

" ....................{ COPIERS                           }....................
" vimrc#copy_messages_to_clipboard() -> None
"
" Copy the contents of all prior Vim messages (i.e., output of the ":messages"
" command) into the system clipboard.
function! vimrc#copy_messages_to_clipboard() abort
    redir @+ | messages | redir END
    echo 'Copied messages to clipboard.'
endfunction

" ....................{ DIFFERS                           }....................
" vimrc#diff_buffer_current_with_file_current() -> None
"
" Review all unsaved changes in the current buffer by diffing the current
" buffer against the corresponding file if any. This function is inspired by
" the DiffOrig() command defined by Vim's stock "vimrc_example.vim" script.
function! vimrc#diff_buffer_current_with_file_current() abort
    vert new
    set bt=nofile
    r ++edit #
    0d_
    diffthis
    wincmd p
    diffthis
endfunction

" ....................{ FORMATTERS                        }....................
" vimrc#sanitize_code_buffer_formatting() -> None
"
" Sanitize the "formatoptions" variable for the current code buffer (i.e.,
" buffer assumed to be currently editing a code-specific filetype).
"
" Specifically, this function enables comment-aware text formatting for
" code-specific filetypes whose syntax supports comments -- regardless of
" whether the plugins configuring these filetypes do so. Since this is Vim, each
" option is signified by a character of the "formatoptions" string global.
"
" This function enables the following options:
"
" * "c", autowrapping all comment lines longer than "textwidth" on the first
"   addition, deletion, or edit of a character in those lines with column
"   greater than "textwidth".
" * "r", autoinserting comment leaders on <Enter> in Insert mode.
" * "o", autoinserting comment leaders on <o> and <O> in Normal mode.
" * "q", autoformatting comments on <gq> in Normal mode.
" * "n", autoformatting commented lists matched by:
"   * "formatlistpat", a standard Vim regular expression matching all lists
"     in comments excluding prefixing comment leader. By default, this
"     expression matches numbered but *NOT* unnumbered lists. A "|"-prefixed
"     regular alternative matching all unnumbered lists prefixed by a
"     Markdown-compatible prefix (i.e., "*", "-", or "+" optionally
"     prefixed by whitespace and mandatorily suffixed by whitespace) is thus
"     appended to this option's default value. Note that this mostly only
"     prevents list items from being concatenated together. In particular,
"     this does *NOT* autoindent the second lines of list items.
" * "j", removing comment leaders when joining lines.
" * "m", breaking long lines at multibyte characters (e.g., for Asian
"   languages in which characters signify words).
" * "B", *NOT* inserting whitespace between adjacent multibyte characters
"   when joining lines.
"
" This function disables the following options:
"
" * "l", preventing long lines from being autowrapped in Insert mode on the
"   first entry into this mode within any such line whose length exceeds
"   "textwidth".
" * "t", preventing long lines from being autowrapped in Insert mode on the
"   first addition, deletion, or edit of a character within any such line whose
"   column exceeds "textwidth".
"
" This function avoids enabling the following options:
"
" * "a", automatically formatting all comments. While this option sounds
"   pleasant in theory, it behaves unpleasantly destructively in practice,
"   rendering most comments uneditable.
"
" For forward compatibility (e.g., to permit Vim to supply improved defaults in
" the future), this list is appended and shifted to with the "+=" and "-="
" operators rather than overwritten with the "=" operator. Note also that:
"
" * The "+=" operator may be safely passed multiple format options to enable.
" * The "-=" operator may *NOT* be safely passed multiple format options to
"   disable. Why? Because Vim interprets this substring literally and hence
"   only disables a sequence of multiple format options if that exact sequence
"   appears in the current sequence of format options. For example,
"   "setlocal formatoptions-=lt" only disables the "l" and "t" format options if
"   the current "formatoptions" string global contains a literal "lt" substring.
"   Since this is horrible, the "-=" operator may only be safely passed a single
"   format option at a time. Who decided this was a sane idea, Bram?
"
" See ":h fo-table" for further details.
function! vimrc#sanitize_code_buffer_formatting() abort
    setlocal formatoptions+=cjmnoqrB
    setlocal formatoptions-=l
    setlocal formatoptions-=t
    setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*\\\|^\\s*[*-+]\\s\\+
endfunction

" ....................{ HIGHLIGHTERS                      }....................
" vimrc#print_syntax_group_current() -> str
"
" Display the names of both the originating and translated syntax groups
" applied to the current character of the current buffer in the status bar.
"
" This function was gratefully inspired by the following external source:
"
" * Laurence Gonsalves's SynGroup() function, published at:
"   https://stackoverflow.com/a/37040415/2809027
function! vimrc#print_syntax_group_current() abort
    " Integer uniquely identifying the originating syntax group applied to the
    " current character of the current buffer. Dismantled, this is:
    "
    " * "line('.')", the current line number.
    " * "col('.')", the current column number.
    let l:syntax_group_id = synID(line('.'), col('.'), 1)

    " Log the names of the current originating and translated syntax groups.
    " Dismantled, this is:
    "
    " * "synIDattr(...)", the name of the originating syntax group.
    " * "synIDtrans(...)", the integer uniquely identifying the syntax group
    "   to which the originating syntax group is translated.
    echo
      \ synIDattr(l:syntax_group_id, 'name') . ' -> ' .
      \ synIDattr(synIDtrans(l:syntax_group_id), 'name')
endfunction


" vimrc#synchronize_syntax_highlighting() -> None
"
" Synchronize syntax highlighting in the current buffer. This function is
" typically manually called by the user *AFTER* a failure by Vim to properly
" highlight this buffer.
function! vimrc#synchronize_syntax_highlighting() abort
    " Log this attempt.
    echo 'Synchronize syntax highlighting...'

    " Reparse syntax from a reasonable number of prior lines in this buffer on
    " every buffer movement. This is more conservative than the default of
    " reparsing syntax from the beginning of this buffer on every buffer
    " movement -- which, in theory, *SHOULD* improve the probability of success
    " in resynchronizing syntax highlighting.
    syntax sync minlines=1024

    " Reparse syntax from the beginning of this buffer on every buffer
    " movement. Although this synchronization setting is already the default
    " for this collection of startup scripts, resetting this setting incurs no
    " penalties and can in edge cases produce tangible benefits.
    " syntax sync fromstart

    " Reenable syntax highlighting. Although syntax highlighting is, of course,
    " already enabled by default by this collection of startup scripts,
    " reenabling syntax highlighting appears to be required in edge cases.
    syntax on
endfunction

" ....................{ PRINTERS ~ buffer                 }....................
" vimrc#print_buffer_current_byte_offset() -> None
"
" Print the 1-based byte offset of the current position in the current buffer.
"
" This function returns the same value displayed by the "%o" statusline
" modifier, and is principally intended for users preferring to manually call
" this function rather than continually display a statusline offset.
"
" Note that the built-in goto() command jumps to an arbitrary byte offset
" (e.g., ":goto 25647", jumping to the 25647th byte in the current buffer).
"
" This function was gratefully inspired by the following external source:
"
" * lcd047's FileOffset() function, published at:
"   https://vi.stackexchange.com/a/3850
function! vimrc#print_buffer_current_byte_offset() abort
    echo line2byte(line('.')) + col('.') - 1
endfunction

" ....................{ WINDOWS                           }....................
" vimrc#switch_window(key: char) -> None
"
" Contextually navigate to the window associated with the passed single letter.
"
" This letter *MUST* be either:
"
" * "j", switching to the window under the current window.
" * "k", switching to the window above the current window.
" * "h", switching to the window to the left of the current window.
" * "k", switching to the window to the right of the current window.
"
" If the window to be navigated to exists, this function simply switches to
" that window; else, this function splits the current window (horizontally if
" the passed keystroke is either "j" or "k" and vertically otherwise) and
" switch to the new window.
"
" This function was gratefully inspired by the following external source:
"
" * Nick Verlinde's WinMove() function, published at:
"   http://www.agillo.net/simple-vim-window-management/
function! vimrc#switch_window(key) abort
    " Validate sanity.
    if match(a:key, '[hjkl]') != 0
        throw
          \ 'Window navigation key "' . a:key .
          \ '" not "h", "j", "k", or "l".'
    endif

    " 1-based identifier of the current window.
    let l:window_current_id = winnr()

    " Attempt the desired window switch.
    exec 'wincmd ' . a:key

    " If no window was switched to, split the current window and try again. 
    if l:window_current_id == winnr()
        " Perform the appropriate window split.
        if match(a:key, '[jk]') == 0
            wincmd s
        else 
            wincmd v
        endif

        " Perform the desired window switch.
        exec 'wincmd ' . a:key
    endif
endfunction
