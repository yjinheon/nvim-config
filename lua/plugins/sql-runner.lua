return {
  {
    -- load local module as a "plugin"
    dir = vim.fn.stdpath("config") .. "/lua/local/sql_runner",
    name = "sql-runner",
    dependencies = { "nvim-telescope/telescope.nvim" },
    --ft = "sql", -- only when editing *.sql
    init = function()
      local function mod(fn)
        return function(...)
          require("local.sql_runner")[fn](...)
        end
      end

      -- Commands
      vim.api.nvim_create_user_command("RunSQL", mod("run_sql_selection"), { range = true })
      vim.api.nvim_create_user_command("RunSQLBuffer", mod("run_sql_buffer"), {})
      vim.api.nvim_create_user_command("SelectSqlCmd", mod("select_command"), {})

      vim.api.nvim_create_user_command("SaveSqlFile", mod("save_query_file"), { range = true })
      vim.api.nvim_create_user_command("OpenSqlFile", mod("open_query_file"), {})
      vim.api.nvim_create_user_command("RemoveSqlFile", mod("remove_query_file"), {})
      vim.api.nvim_create_user_command("RunSqlFromDir", mod("run_sql_from_dir"), {}) -- NEW

      -- Keymaps (buffer-local because ft=sql)
      -- vim.keymap.set(
      --   "v",
      --   "<leader>cdr",
      --   "<cmd>RunSQL<CR>",
      --   { silent = true, desc = "Run SQL (visual selection)", buffer = true }
      -- )
      -- vim.keymap.set(
      --   "n",
      --   "<leader>cdR",
      --   "<cmd>RunSQLBuffer<CR>",
      --   { silent = true, desc = "Run SQL (entire buffer)", buffer = true }
      -- )
      -- vim.keymap.set(
      --   "n",
      --   "<leader>cdc",
      --   "<cmd>SelectSqlCmd<CR>",
      --   { silent = true, desc = "Select SQL backend", buffer = true }
      -- )
      --
      -- vim.keymap.set(
      --   "v",
      --   "<leader>cdw",
      --   "<cmd>SaveSqlFile<CR>",
      --   { silent = true, desc = "Save selection to .sql file", buffer = true }
      -- )

      vim.keymap.set(
        "n",
        "<leader>Xl",
        "<cmd>OpenSqlFile<CR>",
        { silent = true, desc = "Open .sql file from queries dir", buffer = true }
      )
      vim.keymap.set(
        "n",
        "<leader>Xd",
        "<cmd>RemoveSqlFile<CR>",
        { silent = true, desc = "Remove .sql file from queries dir", buffer = true }
      )

      -- NEW: pick & run from queries dir
      -- vim.keymap.set(
      --   "n",
      --   "<leader>cds",
      --   "<cmd>RunSqlFromDir<CR>",
      --   { silent = true, desc = "Run SQL picked from queries dir", buffer = true }
      -- )
    end,
    config = function() end,
  },
}
