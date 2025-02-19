return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      -- file and directory options
      dir_path = "static/images",
    },
  },
  keys = {
    -- suggested keymap
    { "<leader>ip", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
