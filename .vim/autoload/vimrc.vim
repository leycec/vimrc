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

" ....................{ GETTERS                            }....................
" Get the function with the passed name declared by the script with the passed
" absolute path. This function is principally intended to break the thin veneer
" of privacy provided by "s:". See GetScriptSID() for details. This function is
" appropriated wholesale from the following external function, for which we are
" (again) indelicately grateful:
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
" script declaring such functions). This function is inspired by the following
" external function, for which we are effervescently grateful:
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

    " Parse such output as follows:
    "
    " * Split such output on newlines. Vim guarantees each resulting line to be
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

    " If such script has *NOT* been sourced yet, print a non-fatal warning.
    if l:script_line == -1
        throw '"' . l:script_filename . '" not previously sourced.'
    endif

    " Return the line number of such script -- which, by Vim design, is
    " guaranteed to be such script's SID.
    return l:script_line + 1
endfunction

" --------------------( WASTELANDS                         )--------------------
