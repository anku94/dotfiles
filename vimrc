if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

set wildignore+=.git,node_modules

if has("unix")
  call plug#begin('~/.vim/plugged')
else
  call plug#begin('~\vimfiles\plugged')
endif
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
" Plug 'vim-syntastic/syntastic'
" Install ruby-dev first
Plug 'wincent/command-t', {
    \   'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make'
    \ }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'altercation/vim-colors-solarized'
Plug 'mechatroner/rainbow_csv'
Plug 'crusoexia/vim-monokai'
Plug 'valloric/youcompleteme'
Plug 'tpope/vim-fugitive'
Plug 'fatih/vim-go'
Plug 'kana/vim-operator-user'
Plug 'rking/ag.vim'
Plug 'rhysd/vim-clang-format'
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'lervag/vimtex'
call plug#end()

call glaive#Install()

if has("gui_running")
  " Set a nicer font.  set guifont=Consolas:h11:cDEFAULT
  " Hide the toolbar.
  set guioptions-=T
endif

imap jk <Esc> 
filetype plugin indent on
syntax on
set nu
set tabstop=2
set shiftwidth=2
set expandtab
let NERDSpaceDelims=1

" Syntastic default settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" Airline tab line
let g:airline#extensions#tabline#enabled = 1

let g:vimtex_view_method = 'skim'
let g:tex_flavor = "latex"

" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 0
" let g:syntastic_check_on_wq = 0

" let g:syntastic_javascript_checkers=['eslint']
" let g:syntastic_javascript_eslint_exe = 'npm run lint --'
"
syntax enable
set background=dark
" let g:solarized_termcolors=256
colorscheme monokai
set encoding=utf-8
" color solarized

" disable annoying audio bell
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

" <CTRL>-w m : mark first window
" <CTRL>-w m : swap with that window
let s:markedWinNum = -1

function! MarkWindowSwap()
    let s:markedWinNum = winnr()
endfunction

function! DoWindowSwap()
    "Mark destination
    let curNum = winnr()
    let curBuf = bufnr( "%" )
    exe s:markedWinNum . "wincmd w"
    "Switch to source and shuffle dest->source
    let markedBuf = bufnr( "%" )
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' curBuf
    "Switch to dest and shuffle source->dest
    exe curNum . "wincmd w"
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' markedBuf
endfunction

function! WindowSwapping()
    if s:markedWinNum == -1
        call MarkWindowSwap()
    else
        call DoWindowSwap()
        let s:markedWinNum = -1
    endif
endfunction

nnoremap <C-w>m :call WindowSwapping()<CR>

let g:airline_powerline_fonts = 1
