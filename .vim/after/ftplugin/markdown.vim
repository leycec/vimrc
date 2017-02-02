" --------------------( LICENSE                            )--------------------
" Copyright 2015-2017 by Cecil Curry.
" See "LICENSE" for further details.
"
" --------------------( SYNOPSIS                           )--------------------
" GitHub flavoured Markdown (GFMD)-specific settings applied to all files of
" filetype ".md".

" ....................{ PREAMBLE                           }....................
" If this plugin has already been loaded for the current buffer, return.
if exists("b:is_our_ftplugin")
    finish
endif

" ....................{ BINDINGS                           }....................
" If the the external Google Chrom[e|ium] browser is installed, assume that the
" optional "Markdown Preview Plus" extension is also installed for this browser.
" In this case, bind <,p> to begin previewing the current Markdown buffer. To
" update an existing preview, simply hit <F5> or <Ctrl-r> in the open tab.
"
" To install this open-source extension, open Chrom[e|ium] and:
"
" * Browse to the following URL:
"   https://chrome.google.com/webstore/detail/markdown-preview-plus/febilkbfcbhebfnokafefeacimjdckgl
" * Select "ADD TO CHROME".
" * Browse to the following URL:
"   chrome://extensions/
" * Scroll down to the "Markdown Preview Plus" section.
" * Check the "Allow access to file URLs" checkbox.
"
" As with Markdown bundles, there exist a variety of Markdown preview bundles.
" Since *ALL* such bundles have mandatory non-trivial platform-specific
" dependencies (or are unsupported on various platforms), the Chrom[e|ium]
" approach is strongly preferable for portability. These bundles include:
"
" * "suan/vim-instant-markdown", implementing GitHub-flavoured Markdown (GFMD)
"   preview via Node.js. Frequently updated and fast on large buffers.
"   Unsurprisingly, this is the most popular Markdown preview bundle.
" * "JamshedVesuna/vim-markdown-preview", implementing GitHub-flavoured Markdown
"   (GFMD) preview via "grip" and "xdotool". Unfortunately, the use of "xdotool"
"   limits the portability of this bundle. Windows remains unsupported.

if g:our_is_platform_linux
    " Under Linux distributions, prefer Chromium (a strictly open-source 
    " variant) to Chrome (the partially closed-source default).
    if executable('chromium')
        noremap <buffer> <localleader>p !command chromium %:p<cr>
    elseif executable('chrome')
        noremap <buffer> <localleader>p !command chrome %:p<cr>
    endif
"FIXME: Is the test for this application correct? How *DOES* one test for the
"existence of an application bundle, anyway?
elseif g:our_is_platform_macos && executable('Google Chrome')
    noremap <buffer> <localleader>p :!open -a "Google Chrome.app" %:p<cr>
elseif g:our_is_platform_windows && executable('chrome.exe')
    noremap <buffer> <localleader>p :!start chrome.exe %:p<cr>
endif

" ....................{ FORMAT                             }....................
" Enable the following auto-formatting options for plaintext files:
"
" * "2", indenting plaintext according to the indentation of the second
"   rather than first line of the current paragraph.
"
" Ideally, option "a" autoformatting paragraphs (i.e., contiguous substrings
" separated by blank lines) would be enabled. However, such autoformatting
" behaves overzealously for our tastes and is hence disabled.
"
" Disable the following auto-formatting options for plaintext files:
"
" * "c", autoformatting comments. By definition, plaintext files are *NOT*
"   commentable in a standardized manner.
" setlocal formatoptions+=2 formatoptions-=c

" Restore our preferred line length. The "ftplugin/markdown.vim" file within
" the "gabrielelana/vim-markdown" bundle maliciously overrides this option for
" this filetype and hence must itself be overridden.
let &textwidth = g:our_textwidth

" ....................{ POSTAMBLE                          }....................
" Declare this plugin to have been successfully loaded for the current buffer.
let b:is_our_ftplugin = 1
