require("mason").setup()

local lspconfig = require("lspconfig")
local lsp_utils = require("lsp_util")
local coq = require("coq")
local navic = require("nvim-navic")
local navbuddy = require("nvim-navbuddy")
local conform = require("conform")

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

local lsp_defaults = {
    inlay_hints = {
        enabled = false
    }
}

-- Pyright LSP config --
local pyright_conf = {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        navic.attach(client, bufnr)
        navbuddy.attach(client, bufnr)
    end,
    settings = lsp_utils.get_pyright_settings()
}

if lspconfig["pyright"] then
    lspconfig["pyright"].setup(pyright_conf)
end

-- Bash LSP config --
local bashls_conf = {
    capabilities = capabilities,
    setup = {
        bashIde = {
            loglevel = "info"
        }
    }
}

if lspconfig["bashls"] then
    lspconfig["bashls"].setup(bashls_conf)
end

-- Lua LSP config --
local lua_ls_conf = {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath("config") and
                (vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc")) then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT"
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {vim.env.VIMRUNTIME}
            }
        })
    end,
    settings = {
        Lua = {}
    }
}

if lspconfig["lua_ls"] then
    lspconfig["lua_ls"].setup(lua_ls_conf)
end

-- Clangd LSP config --
local clangd_conf = {
    cmd = {"clangd", "--enable-config"},
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        navic.attach(client, bufnr)
        navbuddy.attach(client, bufnr)
        vim.lsp.inlay_hint.enable(false)
    end
}
if lspconfig["clangd"] then
    lspconfig["clangd"].setup(clangd_conf)
end

-- jsonnet_ls LSP config --
local jsonnet_ls_conf = {
    capabilities = capabilities
}
if lspconfig["jsonnet_ls"] then
    lspconfig["jsonnet_ls"].setup(jsonnet_ls_conf)
end

-- jsonnet LSP config --
-- local jsonnetfmt_conf = {
--     capabilities = capabilities
-- }
-- if lspconfig["jsonnetfmt"] then
--     lspconfig["jsonnetfmt"].setup(jsonnetfmt_conf)
-- end

-- Efm LSP config --
local efm_conf = {
    cmd = {"efm-langserver", "-logfile", "/tmp/efm.log", "-loglevel", "10"},
    init_options = {
        documentFormatting = true
    },
    filetypes = {"sh", "python", "lua", "cmake", "tex", "bib", "lua"}
}
if lspconfig["efm"] then
    lspconfig["efm"].setup(efm_conf)
end

-- Rust Analyzer LSP config --
local rust_analyzer_conf = {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        navic.attach(client, bufnr)
        navbuddy.attach(client, bufnr)
    end
}
if lspconfig["rust_analyzer"] then
    lspconfig["rust_analyzer"].setup(rust_analyzer_conf)
end

-- Conform LSP config --
local conform_conf = {
    formatters_by_ft = {
        sh = {"shfmt"},
        python = {"black"},
        lua = {"stylua"},
        cmake = {"cmake-format"},
        jsonnet = {"jsonnetfmt"}
    }
}
conform.setup(conform_conf)

-- Mason LSP config --
local mason_lspconfig_conf = {
    ensure_installed = {"pyright", "clangd", "bashls", "efm", "rust_analyzer", "jsonnet_ls", "lua_ls"}
}
require("mason-lspconfig").setup(mason_lspconfig_conf)

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = {
            buffer = ev.buf
        }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set({"n", "v"}, "<space>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<space>F", function()
            vim.lsp.buf.format({
                async = true
            })
        end, opts)
        -- <space>nf is for formatting with conform.nvim
        -- <space>F is for formatting with lsp
        vim.keymap.set("n", "<space>dd", function()
            -- add a message to make sure this gets called
            print("formatting with conform.nvim")
            conform.format({bufnr = ev.buf})
        end, opts)

        -- Disable inlay hints for now
        -- Enable inlay hints if supported by client; return if not
        -- local id = vim.tbl_get(ev, "data", "client_id")
        -- local client = id and vim.lsp.get_client_by_id(id)
        -- if client == nil or not client.supports_method("textDocument/inlayHints") then
        -- 	return
        -- end

        -- vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
})
