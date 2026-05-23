-- local user_config = vim.g.config.plugins.dap or {}

-- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation.md

local user_config = {}
--
-- ---From https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/go.lua#L145
-- ---@param config {args?:string[]|fun():string[]?}
-- local function get_args(config)
--   local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
--   config = vim.deepcopy(config)
--   ---@cast args string[]
--   config.args = function()
--     local new_args = vim.fn.input("Run with args: ", table.concat(args, " ")) --[[@as string]]
--     return vim.split(vim.fn.expand(new_args) --[[@as string]], " ")
--   end
--   return config
-- end
--
-- stylua: ignore
local default_config = {
  dap = {
    keys = {
      {"<leader>d", "", desc = "+Debug" },
    --  { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
     -- { "<leader>dc", function() require("dap").run_to_cursor() end, desc = "Continue" },
     -- vim.keymap.set('n', '<F5>', require 'dap'.continue)
     -- vim.keymap.set('n', '<F10>', require 'dap'.step_over)
     -- vim.keymap.set('n', '<F11>', require 'dap'.step_into)
     -- vim.keymap.set('n', '<F12>', require 'dap'.step_out)
     -- vim.keymap.set('n', '<leader>b', require 'dap'.toggle_breakpoint)

     --step over : 한줄을 실행합니다. 함수가 있어도 실행 후 다음으로 넘어갑니다.
     --step into : 함수 내부로 들어갑니다.
     --step out : 함수를 끝까지 실행시키고 호출시킨 곳으로 되돌아 갑니다.
       { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<F2>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>du", function() require("dap").up() end, desc = "Up" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
--      { "<leader>dS", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
      { "<leader>ds", function() require("dap").continue() end, desc = "Run" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor", },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dK", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
  },
  dap_ui = {
    keys = {
      { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
      { "<leader>dE", function() require("dapui").eval() end, desc = "Eval", mode = { "n", "v" } },
    },
    opts = {},
  },
  dap_virtual_text = {
    opts = {
      commented = true,
    },
  },
  dap_python = {
    keys = require("lang.python").dap_keys(),
  },
}

local config = vim.tbl_deep_extend("force", default_config, user_config)

return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    keys = config.dap.keys,
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = "nvim-neotest/nvim-nio",
        keys = config.dap_ui.keys,
        opts = config.dap_ui.opts,
        config = function(_, opts)
          local dap, dapui = require("dap"), require("dapui")
          dapui.setup(opts)
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
          end

          local dap_breakpoint = {
            error = {
              text = "🟥",
              texthl = "DiagnosticsSignError",
              linehl = "",
              numhl = "",
            },
            rejected = {
              text = "",
              texthl = "DiagnosticsSignHint",
              linehl = "",
              numhl = "",
            },
            stopped = {
              text = "⭐️",
              texthl = "DiagnosticsSignInfo",
              linehl = "DiagnosticUnderlineInfo",
              numhl = "DiagnosticsSignInfo",
            },
          }
          vim.fn.sign_define("DapBreakpoint", dap_breakpoint.error)
          vim.fn.sign_define("DapStopped", dap_breakpoint.stopped)
          vim.fn.sign_define("DapBreakpointRejected", dap_breakpoint.rejected)
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = config.dap_virtual_text.opts,
        config = function(_, opts)
          require("nvim-dap-virtual-text").setup(opts)
        end,
      },
      {
        "mfussenegger/nvim-dap-python",
        keys = config.dap_python.keys,
        config = function()
          require("lang.python").setup_dap()
        end,
      },
    },
    opts = {
      setup = {
        kotlin_debug_adapter = function()
          require("lang.kotlin").setup_dap()
        end,
      },
    },
  },
}
