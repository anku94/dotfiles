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
" Install ruby-dev first, fuzzy file finder <Leader>t
" We prefer fzf instead
" Plug 'wincent/command-t', {
    " \   'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make'
    " \ }

" Just visual enhancements
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'altercation/vim-colors-solarized'
Plug 'crusoexia/vim-monokai'

" Old, unused plugins
" Plug 'valloric/youcompleteme'
" Plug 'fatih/vim-go'
" A git wrapper for vim, probably don't use this
" Plug 'tpope/vim-fugitive'
" This is probably a dependency, maybe of codefmt?
Plug 'kana/vim-operator-user'
" Plug 'rking/ag.vim'
Plug 'rhysd/vim-clang-format'
Plug 'vim-scripts/DoxygenToolkit.vim'
Plug 'Vimjas/vim-python-pep8-indent'

" these 3 are needed for codefmt
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'google/vim-codefmt'
" This links with codefmt, not totally sure
Plug 'Vimjas/vim-python-pep8-indent'

Plug 'mechatroner/rainbow_csv'

" Python REPL, <leader>W
Plug 'sillybun/vim-repl'

" Fuzzy finder, :Files/:Buffers etc
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'lervag/vimtex'
call plug#end()

call glaive#Install()
Glaive codefmt plugin[mappings]
Glaive codefmt shfmt_executable="/users/ankushj/go/bin/shfmt"

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

" vim-repl
let g:mapleader=' '
let g:repl_position = 3
nnoremap <leader>r :REPLToggle<Cr>
nnoremap <leader>e :REPLSendSession<Cr>
let g:repl_program = {
            \   'python': 'ipython',
            \   'default': 'zsh',
            \   'r': 'R',
            \   'lua': 'lua',
            \   'vim': 'vim -e',
            \   }
