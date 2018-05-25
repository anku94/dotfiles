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
Plug 'vim-syntastic/syntastic'
" Install ruby-dev first
Plug 'wincent/command-t', {
    \   'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make'
    \ }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'altercation/vim-colors-solarized'
Plug 'crusoexia/vim-monokai'
Plug 'valloric/youcompleteme'
Plug 'tpope/vim-fugitive'
Plug 'fatih/vim-go'
call plug#end()

if has("gui_running")
  " Set a nicer font.
  set guifont=Consolas:h11:cDEFAULT
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

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

let g:syntastic_javascript_checkers=['eslint']
"let g:syntastic_javascript_eslint_exe = 'npm run lint --'
"
syntax enable
set background=dark
" let g:solarized_termcolors=256
colorscheme monokai
set encoding=utf-8
# color solarized

" disable annoying audio bell
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=
