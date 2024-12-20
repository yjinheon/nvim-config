return {
  "mfussenegger/nvim-dap",

  dependencies = {
    -- fancy UI for the debugger
    {
      {
        "rcarriga/nvim-dap-ui",
        config = function()
          require("dapui").setup()
        end,
      },
      {
        "mfussenegger/nvim-dap-python",
        keys = {
          {
            "<leader>dap",
            function()
              require("dap-python").test_method()
            end,
            desc = "Debug Python Method",
          },
          {
            "<leader>daP",
            function()
              require("dap-python").test_class()
            end,
            desc = "Debug Python Class",
          },
        },

        config = function(_, opts)
          require("dap-python").setup("/usr/bin/python")
          require("dap-python").test_runner = "pytest"
          local dap = require("dap")
          local venv = os.getenv("VIRTUAL_ENV") or "/usr"
          local python_executable = venv .. "/bin/python"
          dap.adapters.python = {
            type = "executable",
            command = python_executable,
            args = { "-m", "debugpy.adapter" },
          }
        end,
      },
      {
        "leoluz/nvim-dap-go",
        keys = {
          {
            "<leader>dag",
            function()
              require("dap-go").debug_test()
            end,
            desc = "Debug Go Method",
          },
        },
        config = function(_, opts)
          local dap = require("dap")
          dap.configurations.go = {
            {
              type = "go",
              name = "Debug",
              request = "launch",
              program = "${file}",
            },
            {
              type = "go",
              name = "Debug test", -- configuration for debugging test files
              request = "launch",
              mode = "test",
              program = "${file}",
            },
            -- works with go.mod packages and sub packages
            {
              type = "go",
              name = "Debug test (go.mod)",
              request = "launch",
              mode = "test",
              program = "./${relativeFileDirname}",
            },
          }
          dap.adapters.go = function(callback, config)
            local stdout = vim.loop.new_pipe(false)
            local handle
            local pid_or_err
            local port = 38697
            local opts = {
              stdio = { nil, stdout },
              args = { "dap", "-l", "127.0.0.1:" .. port },
              detached = true,
            }
            handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
              stdout:close()
              handle:close()
              if code ~= 0 then
                print("dlv exited with code", code)
              end
            end)
            assert(handle, "Error running dlv: " .. tostring(pid_or_err))
            stdout:read_start(function(err, chunk)
              assert(not err, err)
              if chunk then
                vim.schedule(function()
                  require("dap.repl").append(chunk)
                end)
              end
            end)
            -- Wait for delve to start
            vim.defer_fn(function()
              callback({ type = "server", host = "127.0.0.1", port = port })
            end, 100)
          end
        end,
      },
    },
  },

  -- stylua: ignore
  keys = {
    -- Running the program
    { "<leader>dr", "<cmd>Telescope dap configurations<cr>", desc = "run" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "run last" },
    { "<leader>dR", function() require("dap").restart() end, desc = "restart" },
    { "<leader>dq", function() require("dap").terminate() end, desc = "terminate" },
    -- steps
    { "<leader>dp", function() require("dap").step_back() end, desc = "step back" }, -- [p]revious
    { "<leader>dn", function() require("dap").step_over() end, desc = "step over" }, -- [n]ext
    { "<leader>di", function() require("dap").step_into() end, desc = "step into" }, -- [i]nto
    { "<leader>do", function() require("dap").step_out() end, desc = "step out" },   -- [o]ut, [u]ninto
    { "<leader>dc", function() require("dap").continue() end, desc = "continue" },   -- Run until breakpoint or program termination
    { "<leader>dh", function() require("dap").run_to_cursor() end, desc = "step to here(cursor)" }, -- step to [h]ere
    -- breakpoints
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "[B] toggle breakpoint" },
    { "<leader>da", "<cmd>Telescope dap list_breakpoints<cr>", desc = "[B] show all breakpoints" },
    { "<leader>dx", function() require("dap").clear_breakpoints() end, desc = "[B] removes all breakpoints" },
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "[B] conditional breakpoint" },
    { "<leader>dL", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "[B] logpoint" },
    -- dapui
    { "<leader>du", function() require("dapui").toggle() end, desc = "toggle dapui" },
    -- watch expressions
    { "<A-e>", function() require("dapui").eval() end, desc = "eval (<A-e>)", mode = { "n", "v" } },
    { "<leader>dk", function() require("dapui").eval() end, desc = "eval (<A-e>)", mode = { "n", "v" } },
    { "<leader>dK", function() require("dap.ui.widgets").preview() end, desc = "preview expression"},
  },

  config = function()
    local dap = require("dap")
    dap.defaults.fallback.external_terminal = {
      command = "kitty",
      args = { "-e" },
    }

    -- https://microsoft.github.io/vscode-codicons/dist/codicon.html
    vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "", linehl = "", numhl = "" }) -- debug-breakpoint-conditional
    vim.fn.sign_define("DapLogPoint", { text = "", texthl = "", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "", texthl = "", linehl = "", numhl = "" })

    require("dap.repl").commands = vim.tbl_extend("force", require("dap.repl").commands, {
      continue = { ".continue", "c" },
      next_ = { ".next", "n" },
      into = { ".into", "s" },
      into_targets = { "st" },
      out = { ".out", "r" },
      scopes = { ".scopes", "a" },
      threads = { ".threads", "t", "threads" },
      frames = { ".frames", "f", "bt" },
      exit = { "exit", ".exit", "q" },
      up = { ".up", "up" },
      down = { ".down", "down" },
      goto_ = { ".goto", "j" },
      capabilities = { ".capabilities", ".ca" },
      custom_commands = {
        [".echo"] = function(text)
          dap.repl.append(text)
        end,
      },
    })
  end,
}
