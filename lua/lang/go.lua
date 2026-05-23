local M = {}

M.filetypes = { "go", "gomod", "gowork", "gotmpl" }

function M.setup_globals()
  vim.g.go_fmt_autosave = 0
  vim.g.go_gopls_gofumpt = 0
end

function M.lsp_servers()
  return {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  }
end

function M.mason_tools()
  return { "goimports", "gofumpt", "delve", "golangci-lint" }
end

function M.formatters()
  return { "goimports", "gofumpt" }
end

function M.golangci_lint_cmd()
  return vim.fn.expand("~/go/bin/golangci-lint")
end

function M.run_current_file()
  vim.cmd("write")
  require("util.terminal_runner").run_file("go run", vim.fn.expand("%:p"))
end

function M.setup_keymaps(bufnr)
  vim.keymap.set("n", "<F6>", M.run_current_file, {
    buffer = bufnr,
    desc = "Run Go file",
    noremap = true,
  })
end

function M.setup_dap()
  local dap = require("dap")

  dap.configurations.go = {
    {
      type = "delve",
      name = "file",
      request = "launch",
      program = "${file}",
      outputMode = "remote",
    },
  }
end

return M
