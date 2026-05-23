local go = require("lang.go")

return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      go.setup_globals()

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function(event)
          go.setup_keymaps(event.buf)
        end,
        desc = "Go development keymaps",
      })
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, tool in ipairs(go.mason_tools()) do
        if not vim.tbl_contains(opts.ensure_installed, tool) then
          table.insert(opts.ensure_installed, tool)
        end
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        go = go.formatters(),
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        go = { "golangcilint" },
      },
      linters = {
        golangcilint = {
          cmd = go.golangci_lint_cmd(),
        },
      },
    },
  },
  {
    "leoluz/nvim-dap-go",
    ft = go.filetypes,
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
      go.setup_dap()
    end,
  },
}
