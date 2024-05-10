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
require("coq_3p"){
  { src = "copilot", short_name = "COP", accept_key = "<c-f>" },
  { src = "nvimlua", short_name = "nLUA" }
}
