return {
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = function(_, opts)
  --     local servers = { "pyright", "basedpyright", "ruff", "ruff_lsp", ruff, lsp }
  --     for _, server in ipairs(servers) do
  --       opts.servers[server] = opts.servers[server] or {}
  --       opts.servers[server].enabled = server == lsp or server == ruff
  --     end
  --   end,
  --   setup = {
  --     [ruff] = function()
  --       LazyVim.lsp.on_attach(function(client, bufnr)
  --         client.server_capabilities.hoverProvider = false
  --       end, ruff)
  --     end,
  --   },
  -- },
  -- --
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = nil,
        pyright = {
          enabled = false,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off", -- or "strict", "basic"
                reportGeneralTypeIssues = "warning",
                reportUndefinedVariable = "error",
                -- Add other Pyright settings as needed
              },
            },
          },
        },
        ruff = { enabled = false },
        pylsp = {
          -- (optional) ensure pylsp runs from your env that has rope/pylsp-rope
          --cmd = { "uv", "run", "--with", "python-lsp-server,pylsp-rope,python-lsp-ruff", "pylsp" },
          cmd = { "pylsp" },
          settings = {
            pylsp = {
              plugins = {
                -- Rope-based auto-imports
                rope_autoimport = {
                  enabled = true,
                  -- optional extras:
                  -- memory = false,   -- keep a disk DB so startup is faster
                  -- code_actions = true,
                },
                -- Optional: use ruff for linting/organizing imports
                ruff = { enabled = true, format = { "I" } }, -- organize/sort imports
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
              },
            },
          },
        },
      },
    },
  },
  --
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = function(_, opts)
  --     -- Disable other Python LSP servers
  --     opts.servers = opts.servers or {}
  --
  --     opts.servers.pyright = opts.servers.pyright or {}
  --     opts.servers.pyright.enabled = false
  --
  --     opts.servers.ruff = opts.servers.ruff or {}
  --     opts.servers.ruff.enabled = false
  --
  --     -- Configure pylsp
  --     opts.servers.pylsp = opts.servers.pylsp or {}
  --     opts.servers.pylsp.cmd = { "uv", "run", "--with", "python-lsp-server,pylsp-rope,python-lsp-ruff", "pylsp" }
  --     --opts.servers.pylsp.cmd = { "pylsp" }
  --     opts.servers.pylsp.settings = {
  --       pylsp = {
  --         plugins = {
  --           -- Rope-based auto-imports
  --           rope_autoimport = {
  --             enabled = true,
  --             -- optional extras:
  --             -- memory = false,   -- keep a disk DB so startup is faster
  --             code_actions = true,
  --           },
  --           -- Optional: use ruff for linting/organizing imports
  --           ruff = { enabled = true, format = { "I" } }, -- organize/sort imports
  --           pyflakes = { enabled = false },
  --           pycodestyle = { enabled = false },
  --         },
  --       },
  --     }
  --   end,
  -- },
  {
    "onsails/lspkind.nvim",
    lazy = false,
    enabled = true,
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "python-lsp-server",
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettier",
        "pyright",
        "typescript-language-server",
        "flake8",
      },
    },
  },
  {
    "nvimdev/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({
        ui = {
          enable = false,
          sign = false,
          code_action = "",
        },
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter", -- optional
      "nvim-tree/nvim-web-devicons", -- optional
    },
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      bind = true,
      handler_opts = {
        border = "rounded",
      },
    },
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },
}
