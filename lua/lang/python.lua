local M = {}

function M.dap_keys()
  return {
    {
      "<F9>",
      function()
        require("dap-python").test_method()
      end,
      desc = "Debug Method",
      ft = "python",
    },
    {
      "<leader>dpc",
      function()
        require("dap-python").test_class()
      end,
      desc = "Debug Class",
      ft = "python",
    },
    {
      "<leader>dps",
      function()
        require("dap-python").debug_selection()
      end,
      desc = "Debug Selection",
      ft = "python",
    },
  }
end

function M.setup_dap()
  require("dap-python").setup("uv")
end

function M.run_current_file()
  vim.cmd("write")
  require("util.terminal_runner").run_file("python3", vim.fn.expand("%:p"))
end

return M
