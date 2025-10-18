" File: .vimrc
"
" Some bits were inspired by Seth Mason's Vim configuration file:
" https://slackorama.com/projects/vim/vimrc.html
"
set nocompatible                " use Vim defaults instead of 100% vi compatibility
"set verbose=9                  " increase verbosity to see everything vim is doing.

set nobackup                    " do not keep backup files
set nowritebackup               " do not keep backup files
"set autowrite                  " automatically save before commands like :next and :make

set laststatus=2                " always display a status line at the bottom of the window
"set cmdheight=2                " set the commandheight
set showcmd                     " show (partial) command in status line
set history=50                  " keep 50 lines of command line history

set ruler                       " show the cursor position all the time
set incsearch                   " incremental search
set showmatch                   " show matching brackets
set ignorecase                  " Set ignorecase on
set scs                         " smart search (override 'ic' when pattern has uppers)

set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set shiftwidth=4                " 4 spaces for indenting
set tabstop=4                   " show tabs as 4 spaces
"set expandtab                  " use spaces instead of tabs

" Show tab characters
set list
set listchars=tab:>.

set autoindent                  " always set autoindenting on
set linebreak                   " don't wrap words by default
set textwidth=0                 " don't wrap lines by default
"set textwidth=79               " wrap at 80 chars

" Set status line  -  https://vimhelp.org/options.txt.html#'statusline'
set statusline=
set statusline +=[%02n]            " buffer number
set statusline +=\ %F              " full path of file in buffer
set statusline +=\ %(\[%M%R%H]%)%= " modified flag, readonly flag, help buffer flag
set statusline +=\ %4l,%02c%2V     " line number, column number, virtual column number
set statusline +=\ %P%*            " percentage through file

set mouse=a                     " enable use of mouse
set selectmode=mouse            " select when using the mouse

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch

    " Highlight strings inside C comments
    let c_comment_strings=1

    " Avoid syntax highlighting on big files
    " https://stackoverflow.com/a/559052
    autocmd BufWinEnter * if line2byte(line("$") + 1) > 1000000 | syntax clear | endif
endif

" Commands for :Explore
let g:explVertical=1    " open vertical split window
let g:explSplitRight=1  " Put new window to the right of the explorer
let g:explStartRight=0  " new windows go to right of explorer window

" TOhtml command
let html_use_css=1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COMMANDS

"switch to directory of current file
command! CD cd %:p:h

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" KEY MAPPINGS

" Explore
map <Leader>e :Explore<cr>
map <Leader>s :Sexplore<cr>

" Buffer navigation
map <M-Left> :bprevious<CR>
map <M-Right> :bnext<CR>

" Indentation
" '<' / '>' : indent/unindent selected lines
vnoremap < <gv
vnoremap > >gv
" 'tab' / 's-tab' : indent/unindent selected lines in visual mode (keep highlighting):
vmap <tab> >gv
vmap <s-tab> <gv

" <c-a> : select all.
map <c-a> ggVG

" <c-s> : write current buffer.
map <c-s> :w<cr>
imap <c-s> <c-o><c-s>
imap <c-s> <esc><c-s>

" <c-z> : undo in insert mode.
imap <c-z> <c-o>u

" <p> (visual mode) : replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvs<C-R>=current_reg<CR><Esc>

" <Q> : Don't use Ex mode, use Q for formatting
map Q gq

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" AUTOCOMMANDS

if has("autocmd")
    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72, 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    filetype plugin indent on

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler (happens when dropping a file on gvim).
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

    " add an autocommand to update an existing time stamp when writing the file
    " It uses the functions above to replace the time stamp and restores cursor
    " position afterwards (this is from the FAQ)
    autocmd BufWritePre,FileWritePre *   ks|call UpdateTimeStamp()|'s
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ABBREVIATIONS

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  FUNCTIONS

" first add a function that returns a time stamp in the desired format
if !exists("*TimeStamp")
    fun TimeStamp()
        return "Last-modified: " . strftime("%d %b %Y %X")
    endfun
endif

" searches the first ten lines for the timestamp and updates using the
" TimeStamp function
if !exists("*UpdateTimeStamp")
    function! UpdateTimeStamp()
        " Do the updation only if the current buffer is modified
        if &modified == 1
            " go to the first line
            exec "1"
            " Search for Last modified:
            let modified_line_no = search("Last-modified:")
            if modified_line_no != 0 && modified_line_no < 10
                " There is a match in first 10 lines
                " Go to the : in modified:
                exe "s/Last-modified: .*/" . TimeStamp()
            endif
        endif
    endfunction
endif
