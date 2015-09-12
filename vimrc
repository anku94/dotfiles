""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Line Numbering
set nu
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" highlight search results
set hlsearch
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Formatting Options

set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
set smarttab
set expandtab
set ruler " iTerm needed for showing column,line number
set backspace=2 " Needed for backspace to work properly on OSX/iTerm2
syntax on
filetype plugin indent on

" Toggle pastemode
nnoremap <F3> :set paste!<CR>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

execute pathogen#infect()
syntax enable
set background=dark
colorscheme solarized
" colorscheme distinguished

" Number of context lines surrounding - large number causes cursor to be
" centered
set so=999


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" If you prefer the Omni-Completion tip window to close when a selection is
" made, these lines close it on movement in insert mode or when leaving
" insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif
