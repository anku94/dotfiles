require("mason").setup()

local lspconfig = require('lspconfig')
local lsp_utils = require('lsp_util')
local coq = require('coq')
local navic = require("nvim-navic")
local navboddy = require("nvim-navbuddy")

local navic_on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
end

-- Setup lspconfig with updated capabilities.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = coq.lsp_ensure_capabilities(capabilities)
-- local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp
--                                                                       .protocol
--                                                                       .make_client_capabilities())
capabilities.offsetEncoding = {"utf-16"}

-- This setup will automatically use the server installed via Mason
lspconfig['pyright'].setup {capabilities = capabilities,
  on_attach = function(client, bufnr)
    navic.attach(client, bufnr)
    navboddy.attach(client, bufnr)
  end,
  settings = lsp_utils.get_pyright_settings()
}

lspconfig['bashls'].setup {
  capabilities = capabilities,
  setup = {bashIde = {loglevel = "debug"}}
}

lspconfig['clangd'].setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    navic.attach(client, bufnr)
    navboddy.attach(client, bufnr)
  end
}

-- May require manual configuration for more formats here. Overrides null-ls
lspconfig['efm'].setup {
  cmd = { "efm-langserver", "-logfile", "/tmp/efm.log", "-loglevel", "5"},
  init_options = {documentFormatting = true},
  filetypes = {"sh", "python", "lua", "cmake"},
}

require("mason-lspconfig").setup({
  ensure_installed = {"pyright", "clangd", "bashls", "efm"}
})

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = {buffer = ev.buf}
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({'n', 'v'}, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f',
                   function() vim.lsp.buf.format {async = true} end, opts)

    -- Enable inlay hints if supported by client; return if not
    local id = vim.tbl_get(ev, 'data', 'client_id')
    local client = id and vim.lsp.get_client_by_id(id)
    if client == nil or not client.supports_method('textDocument/inlayHints') then
      return
    end

    vim.lsp.inlay_hint.enable(true, {bufnr = ev.buf})
  end
})
