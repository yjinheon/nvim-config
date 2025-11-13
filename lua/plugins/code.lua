return {
  {
    "hedyhli/outline.nvim",
    config = function()
      -- Example mapping to toggle outline
      vim.keymap.set("n", "<leader>cs", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

      require("outline").setup({
        -- Your setup opts here (leave empty to use defaults)
      })
    end,
  },
  {
    "leath-dub/snipe.nvim",
    opts = {
      "<leader>e",
      function()
        require("snipe").open_buffer_menu()
      end,
      desc = "Open Snipe buffer menu",
    },
  },
  --opts = {},
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
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local opts = {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_organize_imports", "ruff_format" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          sh = { "shfmt" },
          css = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          graphql = { "prettier" },
        },
        formatters = {
          prettier = {
            prepend_args = { "--single-quote" },
          },
        },
      }
      return opts
    end,
  },
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
}
