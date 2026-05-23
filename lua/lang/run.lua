local M = {}

local script = vim.fn.stdpath("config") .. "/scripts/run-current-file.sh"

function M.run_current_file()
  local file = vim.fn.expand("%:p")

  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end

  vim.cmd("write")
  require("util.terminal_runner").run_file(vim.fn.shellescape(script), file)
end

return M
