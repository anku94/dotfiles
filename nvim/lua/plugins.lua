require('packer').startup(function()
  -- Add your plugins here, for example:
  -- use 'wbthomason/packer.nvim' -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- for copy to clipboard support; inbuilt in newer neovim versions
  use {'ojroques/nvim-osc52'}

  -- replacement for powerline/airline
  use {
    'nvim-lualine/lualine.nvim',
    requires = {'nvim-tree/nvim-web-devicons', opt = true}
  }
  use 'altercation/vim-colors-solarized'
  use 'tanvirtin/monokai.nvim' -- A monokai theme for Neovim

  -- Additional recommended plugins for Neovim
  -- Treesitter for better syntax highlighting
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

  use {
    "nvim-treesitter/nvim-treesitter-textobjects",
    requires = "nvim-treesitter/nvim-treesitter"
  }

  -- Telescope for fuzzy finding (alternative to fzf)
  use 'nvim-telescope/telescope.nvim'

  -- Native LSP support for language-specific features
  use 'neovim/nvim-lspconfig'
  -- Installer for LSPs
  use 'williamboman/mason.nvim'
  -- Collection of configurations for built-in LSP client
  use 'williamboman/mason-lspconfig.nvim'

  use {'github/copilot.vim'}

  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup({mappings = {basic = true, extra = false}})
    end
  }

  use {'ms-jpq/coq_nvim', branch = 'coq'}
  use {'ms-jpq/coq.artifacts', branch = 'artifacts'}
  use {'ms-jpq/coq.thirdparty', branch = '3p'}

  --
  use 'nvim-lua/plenary.nvim'

  -- For Vim REPL
  use {'Vigemus/iron.nvim'}

  -- For pretty file tree
  use "nvim-tree/nvim-tree.lua"
  use 'nvim-tree/nvim-web-devicons'

  -- For formatters

  -- For nvim-surround
  use 'kylechui/nvim-surround'

  -- For indent-lines
  use 'lukas-reineke/indent-blankline.nvim'

  -- For CSVs
  vim.g.rcsv_colorlinks = {
    'Type', 'Character', 'NONE', 'Constant', 'Number', 'Conditional',
    'Question', 'CursorLineNr', 'ModeMsg'
  }

  use {
    'cameron-wags/rainbow_csv.nvim',
    -- optional lazy-loading below
    config = function()
      -- Set colors for rainbow-csv from highlight groups
      require('rainbow_csv').setup()
    end,
    module = {'rainbow_csv', 'rainbow_csv.fns'},
    ft = {
      'csv', 'tsv', 'csv_semicolon', 'csv_whitespace', 'csv_pipe', 'rfc_csv',
      'rfc_semicolon'
    }
  }

  -- For breadcrumbs - more possible here
  use {"SmiteshP/nvim-navic", requires = "neovim/nvim-lspconfig"}

  use({
    "utilyre/barbecue.nvim",
    tag = "*",
    requires = {
      "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" -- optional dependency
    },
    after = "nvim-web-devicons",
    config = function() require("barbecue").setup() end
  })

  use {
    "SmiteshP/nvim-navbuddy",
    requires = {
      "neovim/nvim-lspconfig", "SmiteshP/nvim-navic", "MunifTanjim/nui.nvim",
      "numToStr/Comment.nvim", -- Optional
      "nvim-telescope/telescope.nvim" -- Optional
    }
  }

  use {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup {}
    end
  }
end)

