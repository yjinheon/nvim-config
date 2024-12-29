return {
  "folke/noice.nvim",
  lazy = false,
  enabled = true,
  opts = function(_, opts)
    -- opts.views = {
    --   cmdline_popup = {
    --     position = {
    --       row = 20,
    --       col = "50%",
    --     },
    --     size = {
    --       width = 60,
    --       height = "auto",
    --     },
    --   },
    --   popupmenu = {
    --     relative = "editor",
    --     position = {
    --       row = 8,
    --       col = "50%",
    --     },
    --     size = {
    --       width = 60,
    --       height = 10,
    --     },
    --     border = {
    --       style = "rounded",
    --       padding = { 0, 1 },
    --     },
    --     win_options = {
    --       winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
    --     },
    --   },
    -- }
    opts.lsp.signature = {
      auto_open = { enabled = false },
    }
  end,
}
