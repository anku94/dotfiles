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
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', {noremap = true})

-- Set clipboard to use the system clipboard
vim.o.clipboard = 'unnamedplus'

-- Enable mouse support
-- vim.o.mouse = 'a'
-- nvim-tree setup (file navigation)
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true
require("nvim-tree").setup()

-- Treesitter keybindings
vim.keymap.set('n', '<leader>ts', ':TSPlaygroundToggle<CR>',
               {noremap = true, silent = true}) -- Toggle Treesitter playground
vim.keymap.set('n', '<leader>th', ':TSHighlightCapturesUnderCursor<CR>',
               {noremap = true, silent = true}) -- Highlight Treesitter captures under cursor

-- Telescope keybindings
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>',
               {noremap = true, silent = true}) -- Find files
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>',
               {noremap = true, silent = true}) -- Live grep
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>',
               {noremap = true, silent = true}) -- List open buffers
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>',
               {noremap = true, silent = true}) -- Search help tags

-- OSC52 bindings
vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr = true})
vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
vim.keymap.set('v', '<leader>c', require('osc52').copy_visual)

require('osc52').setup {
  max_length = 0, -- Maximum length of selection (0 for no limit)
  silent = false, -- Disable message on successful copy
  trim = false, -- Trim surrounding whitespaces before copy
  tmux_passthrough = false -- Use tmux passthrough (requires tmux: set -g allow-passthrough on)
}

require('nvim-surround').setup {}

vim.api.nvim_set_keymap('n', '<F2>', ':NvimTreeToggle<CR>',
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<F3>', ':NvimTreeOpen %:p:h<CR>',
                        {noremap = true, silent = true})

-- Set Ctrl+F as the new leader for window commands (bc Win10 doesnt like Ctlr+W)
vim.api.nvim_set_keymap('n', '<C-c>', '<C-w>', {noremap = true, silent = true})

vim.g.coq_settings = {
  auto_start = 'shut-up' -- Automatically start coq, but silently
}

require('ibl').setup {}
