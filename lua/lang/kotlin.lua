local M = {}

local function mason_package_path(name)
  return vim.fn.stdpath("data") .. "/mason/packages/" .. name
end

local function first_executable(paths)
  for _, path in ipairs(paths) do
    if path and path ~= "" and vim.fn.executable(path) == 1 then
      return path
    end
  end
  return nil
end

function M.lsp_server()
  local mason_kotlin_lsp = mason_package_path("kotlin-lsp")
  local mason_cmd = first_executable({
    vim.fn.exepath("intellij-server"),
    vim.fn.glob(mason_kotlin_lsp .. "/kotlin-server-*/bin/intellij-server", true, true)[1],
    mason_kotlin_lsp .. "/bin/intellij-server",
  })

  return {
    cmd = { mason_cmd or "intellij-server", "--stdio" },
    root_markers = {
      "settings.gradle",
      "settings.gradle.kts",
      "pom.xml",
      "build.gradle",
      "build.gradle.kts",
      "workspace.json",
    },
  }
end

function M.setup_dap()
  local dap = require("dap")

  local exepath = vim.fn.exepath("kotlin-debug-adapter")
  if exepath == "" then
    exepath = mason_package_path("kotlin-debug-adapter") .. "/adapter/bin/kotlin-debug-adapter"
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
