-- Enable syntax highlighting - disabled because interference with treesitter
-- vim.cmd('syntax enable')

-- Set the background color scheme to dark
vim.o.background = 'dark'

-- Set the colorscheme to monokai
vim.cmd('colorscheme monokai')

-- Map 'jk' to escape in insert mode
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', {noremap = true})

-- Enable filetype plugins and indenting
vim.cmd('filetype plugin indent on')

-- Turn on syntax highlighting
vim.cmd('syntax on')

-- Enable line numbers
vim.wo.number = true

-- Set tabstop and shiftwidth
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- Use spaces instead of tabs
vim.o.expandtab = true

-- Set NERDTree space delimiters
-- vim.g.NERDSpaceDelims = 1

-- Airline tab line and powerline fonts
vim.g['airline#extensions#tabline#enabled'] = 1
vim.g.airline_powerline_fonts = 1

-- vim-repl leader key
vim.g.mapleader = ' '

-- Terminal mode mappings for scrolling and entering terminal-normal mode
vim.api.nvim_set_keymap('t', '<C-n>', '<C-w>N', {noremap = true})
vim.api.nvim_set_keymap('t', '<ScrollWheelUp>', '<C-w>Nk', {noremap = true})
vim.api.nvim_set_keymap('t', '<ScrollWheelDown>', '<C-w>Nj', {noremap = true})

-- Set clipboard to use the system clipboard
vim.o.clipboard = 'unnamedplus'

-- Enable mouse support
vim.o.mouse = 'a'

-- Treesitter keybindings
vim.keymap.set('n', '<leader>ts', ':TSPlaygroundToggle<CR>', { noremap = true, silent = true }) -- Toggle Treesitter playground
vim.keymap.set('n', '<leader>th', ':TSHighlightCapturesUnderCursor<CR>', { noremap = true, silent = true }) -- Highlight Treesitter captures under cursor

-- Telescope keybindings
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true }) -- Find files
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true }) -- Live grep
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true }) -- List open buffers
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = true }) -- Search help tags

