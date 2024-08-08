local wk = require("which-key")

local mappings = {
  {"<space>e", desc = "Open Diagnostic Float"},
  {"<space>q", desc = "Set Diagnostic LocList"},
  {"<space>wa", desc = "Add Workspace Folder"},
  {"<space>wr", desc = "Remove Workspace Folder"},
  {"<space>wl", desc = "List Workspace Folders"},
  {"<space>D", desc = "Type Definition"}, {"<space>rn", desc = "Rename"},
  {"<space>ca", desc = "Code Action"}, {"<space>f", desc = "Format"},
  {"gD", desc = "Go to Declaration"}, {"gd", desc = "Go to Definition"},
  {"K", desc = "Hover"}, {"gi", desc = "Go to Implementation"},
  {"<C-k>", desc = "Signature Help"}, {"gr", desc = "References"},
  {"[d", desc = "Previous Diagnostic"}, {"]d", desc = "Next Diagnostic"}
}

wk.add(mappings)

local mappings2 = {
  {
    "<leader>ff",
    "<cmd>Telescope find_files<cr>",
    desc = "Find File",
    group = "+file"
  }, {
    "<leader>fg",
    "<cmd>Telescope live_grep<cr>",
    desc = "Live Grep",
    group = "+file"
  }, {
    "<leader>fb",
    "<cmd>Telescope buffers<cr>",
    desc = "List Buffers",
    group = "+file"
  }, {
    "<leader>fh",
    "<cmd>Telescope help_tags<cr>",
    desc = "Search Help Tags",
    group = "+file"
  }, {
    "<leader>fr",
    "<cmd>Telescope oldfiles<cr>",
    desc = "Open Recent File",
    group = "+file"
  }, {"<leader>fn", "<cmd>enew<cr>", desc = "New File", group = "+file"}
}

wk.add(mappings2)
