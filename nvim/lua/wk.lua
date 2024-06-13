local wk = require("which-key")

local mappings = {
  ["<space>e"] = {nil, "Open Diagnostic Float"},
  ["<space>q"] = {nil, "Set Diagnostic LocList"},
  ["<space>wa"] = {nil, "Add Workspace Folder"},
  ["<space>wr"] = {nil, "Remove Workspace Folder"},
  ["<space>wl"] = {nil, "List Workspace Folders"},
  ["<space>D"] = {nil, "Type Definition"},
  ["<space>rn"] = {nil, "Rename"},
  ["<space>ca"] = {nil, "Code Action"},
  ["<space>f"] = {nil, "Format"},
  ["gD"] = {nil, "Go to Declaration"},
  ["gd"] = {nil, "Go to Definition"},
  ["K"] = {nil, "Hover"},
  ["gi"] = {nil, "Go to Implementation"},
  ["<C-k>"] = {nil, "Signature Help"},
  ["gr"] = {nil, "References"},
  ["[d"] = {nil, "Previous Diagnostic"},
  ["]d"] = {nil, "Next Diagnostic"}
}

wk.register(mappings)

local mappings_ts_t = {
  name = "Treesitter",
  s = {"<cmd>TSPlaygroundToggle<CR>", "Toggle Playground"},
  h = {"<cmd>TSHighlightCapturesUnderCursor<CR>", "Highlight Captures"}
}

wk.register({
  ["<leader>f"] = {
    name = "+file",
    f = { "<cmd>Telescope find_files<cr>", "Find File" },
    g = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
    b = { "<cmd>Telescope buffers<cr>", "List Buffers" },
    h = { "<cmd>Telescope help_tags<cr>", "Search Help Tags" },
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
    n = { "<cmd>enew<cr>", "New File" },
  },
})
