-- Ensure lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Packer can manage itself
  -- { 'wbthomason/packer.nvim' },
  
  -- for copy to clipboard support; inbuilt in newer neovim versions
  { 'ojroques/nvim-osc52' },
  
  -- replacement for powerline/airline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  { 'altercation/vim-colors-solarized' },
  { 'tanvirtin/monokai.nvim' }, -- A monokai theme for Neovim
  
  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
  },
  
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter"
  },
  
  -- Telescope for fuzzy finding (alternative to fzf)
  { 'nvim-telescope/telescope.nvim' },
  
  -- Native LSP support for language-specific features
  { 'neovim/nvim-lspconfig' },
  -- Installer for LSPs
  { 'williamboman/mason.nvim' },
  -- Collection of configurations for built-in LSP client
  { 'williamboman/mason-lspconfig.nvim' },
  
  { 'github/copilot.vim' },
  
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup({ mappings = { basic = true, extra = false } })
    end
  },
  
  -- autocomplete
  { 'ms-jpq/coq_nvim', branch = 'coq' },
  { 'ms-jpq/coq.artifacts', branch = 'artifacts' },
  { 'ms-jpq/coq.thirdparty', branch = '3p' },
  
  { 'nvim-lua/plenary.nvim' },
  
  -- For Vim REPL
  { 'Vigemus/iron.nvim' },
  
  -- For pretty file tree
  { 'nvim-tree/nvim-tree.lua' },
  { 'nvim-tree/nvim-web-devicons' },
  
  -- For nvim-surround
  { 'kylechui/nvim-surround' },
  
  -- For indent-lines
  { 'lukas-reineke/indent-blankline.nvim' },
  
  -- For CSVs
  {
    'cameron-wags/rainbow_csv.nvim',
    config = function()
      vim.g.rcsv_colorlinks = 
      { 'String', 'Comment', 'NONE', 'Conditional', 'PreProc', 'Type', 'Question', 'CursorLineNr',
          'ModeMsg', 'Title' }
      require('rainbow_csv').setup()
    end,
    lazy = true,
    ft = {
      'csv', 'tsv', 'csv_semicolon', 'csv_whitespace', 'csv_pipe', 'rfc_csv',
      'rfc_semicolon'
    }
  },
  
  -- For breadcrumbs - more possible here
  {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig"
  },

  {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons", -- optional dependency
  },
  opts = {},
},
  {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
      "neovim/nvim-lspconfig", "SmiteshP/nvim-navic", "MunifTanjim/nui.nvim",
      "numToStr/Comment.nvim", -- Optional
      "nvim-telescope/telescope.nvim" -- Optional
    }
  },

{
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
},


  
  { 
    'lervag/vimtex',
    lazy = false,
    init = function() end
  },
})
