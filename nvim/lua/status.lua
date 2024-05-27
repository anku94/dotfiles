local navic = require("nvim-navic")
require("lualine").setup({
  sections = {
    lualine_c = {
      "navic",
      color_correction = nil,
      navic_opts = nil
    }
  }
})
