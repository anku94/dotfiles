require('packer').startup(function()
    -- Add your plugins here, for example:
    -- use 'wbthomason/packer.nvim' -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- for copy to clipboard support; inbuilt in newer neovim versions
    use {'ojroques/nvim-osc52'}

    use 'vim-airline/vim-airline'
    use 'vim-airline/vim-airline-themes'
    use 'altercation/vim-colors-solarized'
    use 'tanvirtin/monokai.nvim' -- A monokai theme for Neovim

    -- Additional recommended plugins for Neovim
    -- Treesitter for better syntax highlighting
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

    -- Telescope for fuzzy finding (alternative to fzf)
    use 'nvim-telescope/telescope.nvim'

    -- Native LSP support for language-specific features
    use 'neovim/nvim-lspconfig'
    -- Installer for LSPs
    use 'williamboman/mason.nvim'
    -- Collection of configurations for built-in LSP client
    use 'williamboman/mason-lspconfig.nvim'

    use 'github/copilot.vim'

    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup({mappings = {basic = true, extra = false}})
        end
    }

    use 'hrsh7th/nvim-cmp' -- The completion plugin
    use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
    use 'hrsh7th/cmp-buffer' -- Buffer completions
    use 'hrsh7th/cmp-path' -- Path completions
    use 'hrsh7th/vim-vsnip' -- Snippet engine

    use 'nvim-lua/plenary.nvim'
    use 'jose-elias-alvarez/null-ls.nvim'

    -- For Vim REPL
    use 'Vigemus/iron.nvim'

    -- For pretty file tree
    use "nvim-tree/nvim-tree.lua"
    use 'nvim-tree/nvim-web-devicons'

    -- For formatters
    use 'sbdchd/neoformat'

    -- For nvim-surround
    use 'kylechui/nvim-surround'
end)
