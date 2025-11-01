return {
  "folke/noice.nvim",
  lazy = false,
  enabled = true,
  opts = function(_, opts)
    local function silence(pattern)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          any = {
            { find = pattern },
          },
        },
        opts = { skip = true }, -- 해당 알림 무시
      })
    end
    -- Let Lspsaga handle hover; disable Noice's hover UI
    opts.lsp.hover = vim.tbl_deep_extend("force", opts.lsp.hover or {}, {
      enabled = false,
    })
    silence("No information available")

    silence("Failed to run `config` for nvim%-dap")
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
