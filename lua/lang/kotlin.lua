local M = {}

function M.setup_dap()
  local dap = require("dap")

  local exepath = vim.fn.exepath("kotlin-debug-adapter")
  if exepath == "" then
    exepath = vim.fn.expand("~/.local/share/nvim/mason/packages/kotlin-debug-adapter/adapter/bin/kotlin-debug-adapter")
  end

  dap.adapters.kotlin = {
    type = "executable",
    command = exepath,
    args = { "--stdio" },
  }

  dap.configurations.kotlin = {
    {
      type = "kotlin",
      name = "launch - kotlin",
      request = "launch",
      mainClass = function()
        local root = vim.fs.find("src", { path = vim.uv.cwd(), upward = true, stop = vim.env.HOME })[1] or ""
        local fname = vim.api.nvim_buf_get_name(0)
        local main_class =
          fname:gsub(root, ""):gsub("main/kotlin/", ""):gsub("%.kt$", "Kt"):gsub("/", "."):gsub("^%.", "")
        vim.notify("mainClass=" .. main_class)
        return main_class
      end,
      projectRoot = "${workspaceFolder}",
      jsonLogFile = "",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      stopOnEntry = true,
      enableJsonLogging = false,
    },
    {
      type = "kotlin",
      name = "attach - kotlin",
      request = "attach",
      hostName = "127.0.0.1",
      port = 5005,
      timeout = 30000,
      stopOnEntry = true,
    },
    console = "integratedTerminal",
  }
end

function M.run_current_file()
  if vim.bo.filetype ~= "kotlin" then
    print("This is not a Kotlin file.")
    return
  end

  vim.cmd("write")
  require("util.terminal_runner").run_file("kotlinr", vim.fn.expand("%:p"))
end

return M
