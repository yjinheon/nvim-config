return {
  {
    "simrat39/symbols-outline.nvim",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    cmd = "SymbolsOutline",
    opts = {
      position = "right",
    },
  },
  {
    "leath-dub/snipe.nvim",
    keys = {
      {
        "gb",
        function()
          require("snipe").open_buffer_menu()
        end,
        desc = "Open Snipe buffer menu",
      },
    },
    opts = {},
  },
  -- {
  --   "mhartington/formatter.nvim",
  --   event = { "BufReadPost", "BufNewFile" },
  --   config = function()
  --     local types = "formatter.filetypes."
  --     require("formatter").setup({
  --       filetype = {
  --         python = {
  --           require(types .. "python").ruff,
  --           require(types .. "python").isort,
  --         },
  --       },
  --     })
  --   end,
  -- },
  -- {
  --   "stevearc/conform.nvim",
  --   event = { "BufReadPre", "BufNewFile" },
  --   opts = function()
  --     local opts = {
  --       formatters_by_ft = {
  --         lua = { "stylua" },
  --         python = { "ruff" },
  --         javascript = { "prettier" },
  --         typescript = { "prettier" },
  --         javascriptreact = { "prettier" },
  --         typescriptreact = { "prettier" },
  --         sh = { "shfmt" },
  --         css = { "prettier" },
  --         html = { "prettier" },
  --         json = { "prettier" },
  --         yaml = { "prettier" },
  --         markdown = { "prettier" },
  --         graphql = { "prettier" },
  --       },
  --       formatters = {
  --         prettier = {
  --           prepend_args = { "--single-quote" },
  --         },
  --       },
  --     }
  --     return opts
  --   end,
  -- },
  --
  --
  { "cordx56/rustowl", dependencies = { "neovim/nvim-lspconfig" }, lazy = false },
  -- Go forward/backward with square brackets
  -- {
  --   "echasnovski/mini.bracketed",
  --   event = "BufReadPost",
  --   config = function()
  --     local bracketed = require("mini.bracketed")
  --     bracketed.setup({
  --       file = { suffix = "" },
  --       window = { suffix = "" },
  --       quickfix = { suffix = "" },
  --       yank = { suffix = "" },
  --       treesitter = { suffix = "n" },
  --     })
  --   end,
  -- },
  -- -- {
  --   "ThePrimeagen/refactoring.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   lazy = false,
  --   config = function()
  --     require("refactoring").setup()
  --   end,
  -- },
  {
    "PedramNavid/dbtpal",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    ft = {
      "sql",
      "md",
      "yaml",
    },
    keys = {
      { "<leader>drf", "<cmd>DbtRun<cr>" },
      { "<leader>drp", "<cmd>DbtRunAll<cr>" },
      { "<leader>dtf", "<cmd>DbtTest<cr>" },
      { "<leader>dm", "<cmd>lua require('dbtpal.telescope').dbt_picker()<cr>" },
    },
    config = function()
      require("dbtpal").setup({
        path_to_dbt = "dbt",
        path_to_dbt_project = "",
        path_to_dbt_profiles_dir = vim.fn.expand("~/.dbt"),
        extended_path_search = true,
        protect_compiled_files = true,
      })
      require("telescope").load_extension("dbtpal")
    end,
  },
  {
    "nvim-java/nvim-java",
    config = false,
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        opts = {
          servers = {
            jdtls = {
              -- Your custom jdtls settings goes here
            },
          },
          setup = {
            jdtls = function()
              require("java").setup({
                -- Your custom nvim-java configuration goes here
              })
            end,
          },
        },
      },
    },
  },
}
