" --------------------( LICENSE                            )--------------------
" Copyright 2015 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" Dotfile-specific autoloadable functions, providing custom functionality
" required either conditionally by certain code paths *OR* not at all and hence
" intended to be called manually by the user as "call "-prefixed Ex commands.
"
" By Vim mandate, all functions defined by this script *MUST* be prefixed by
" "vimrc#". In return, Vim sources this script and hence autoloads all such
" functions on the first call to any such function.

" ....................{ TESTERS                            }....................
" 1 if the current buffer should have a corresponding view serialized to and
" deserialized from disk or 0 otherwise.
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

" ....................{ GETTERS ~ script                   }....................
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

" ....................{ DIFFERS                            }....................
" Review all unsaved changes in the current buffer by diffing the current buffer
" against the corresponding file if any. This function is inspired by the
" DiffOrig() command defined by Vim's stock "vimrc_example.vim" script.
function! vimrc#diff_buffer_current_with_file_current() abort
    vert new
    set bt=nofile
    r ++edit #
    0d_
    diffthis
    wincmd p
    diffthis
endfunction

" ....................{ PRINTERS ~ buffer                  }....................
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

" ....................{ WINDOWS                            }....................
" Contextually navigate to the window associated with the passed single letter.
"
" This letter *MUST* be either:
"
" * "j", switching to the window under the current window.
" * "k", switching to the window above the current window.
" * "h", switching to the window to the left of the current window.
" * "k", switching to the window to the right of the current window.
"
" If the window to be navigated to exists, this function simply switches to that
" window; else, this function splits the current window (horizontally if the
" passed keystroke is either "j" or "k" and vertically otherwise) and switch to
" the new window.
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

" --------------------( WASTELANDS                         )--------------------
