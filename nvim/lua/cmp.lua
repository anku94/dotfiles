-- Setup nvim-cmp.
-- local cmp = require("cmp")
--
-- cmp.setup({
--   snippet = {
--     expand = function(args)
--       vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
--     end
--   },
--   mapping = cmp.mapping.preset.insert({
--     ['<C-b>'] = cmp.mapping.scroll_docs(-4),
--     ['<C-f>'] = cmp.mapping.scroll_docs(4),
--     ['<C-Space>'] = cmp.mapping.complete(),
--     ['<C-e>'] = cmp.mapping.close(),
--     ['<CR>'] = cmp.mapping.confirm({select = true}) -- Accept currently selected item.
--   }),
--   sources = cmp.config.sources({{name = 'nvim_lsp'}, {name = 'buffer'}})
-- })
--
--
require("coq_3p") {
  {src = "nvimlua", short_name = "nLUA"}, {src = "vimtex", short_name = "vTEX"}
}

local lazy = require('lazy')
local coq_name = 'coq_nvim'

local function discard_local_changes(plugin_name)
  local plugin_path = vim.fn.stdpath('data') .. '/lazy/' .. plugin_name
  local cmd = 'git -C ' .. plugin_path .. ' reset --hard'

  vim.fn.system(cmd)
end

local function apply_patch(plugin)
  local plugin_path = vim.fn.stdpath('data') .. '/lazy/' .. plugin
  local patch_path = vim.fn.stdpath('config') .. '/patches/' .. plugin ..
                         '.patch'
  local cmd = 'git -C ' .. plugin_path .. ' apply ' .. patch_path
  vim.notify(cmd)

  vim.fn.system(cmd)
end

-- https://github.com/neovim/neovim/issues/12544
-- need to update entire dict
local function enable_coq()
  local settings = vim.g.coq_settings
  settings.completion.always = true
  vim.g.coq_settings = settings
end

local function disable_coq()
  local settings = vim.g.coq_settings
  settings.completion.always = false
  vim.g.coq_settings = settings
end

local function toggle_coq()
  if vim.g.coq_settings.completion.always then
    disable_coq()
    vim.notify("Coq disabled.")
  else
    enable_coq()
    vim.notify("Coq enabled.")
  end
end

function disable_coq_for(seconds)
  disable_coq()
  vim.notify("Coq disabled for " .. seconds .. " seconds.")
  vim.defer_fn(function()
    enable_coq()
    vim.notify("Coq enabled.")
  end, seconds * 1000)
end

function enable_coq_for(seconds)
  enable_coq()
  vim.notify("Coq enabled for " .. seconds .. " seconds.")
  vim.defer_fn(function()
    disable_coq()
    vim.notify("Coq disabled.")
  end, seconds * 1000)
end

vim.api.nvim_create_autocmd('User', {
  pattern = {'LazyUpdatePre', 'LazyCheckPre'},
  callback = function()
    discard_local_changes(coq_name)
    vim.notify("Discarded local changes for coq_nvim")
  end
})

vim.api.nvim_create_autocmd('User', {
  pattern = {'LazyUpdate', 'LazyCheck'},
  callback = function()
    apply_patch(coq_name)
    vim.notify("Applied patch for coq_nvim")
  end
})

-- map <leader>ct to toggle coq
-- vim.api.nvim_set_keymap('n', '<F5>', '<cmd>lua disable_coq_for(30)<cr>',
--                         {noremap = true, silent = false})

vim.api.nvim_set_keymap('n', '<F5>', '<cmd>lua toggle_coq()<cr>',
                        {noremap = true, silent = false})

vim.api.nvim_set_keymap('n', '<F6>', '<cmd>lua enable_coq_for(30)<cr>',
                        {noremap = true, silent = false})

