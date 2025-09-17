return {
  "tpope/vim-dadbod",
  dependencies = {
    { "kristijanhusak/vim-dadbod-ui" },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  opts = {
    -- use dadbod in sql buffer
    db_completion = function()
      ---@diagnostic disable-next-line
      require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
    end,
  },
  config = function(_, opts)
    vim.g.db_ui_use_nerd_fonts = 1
    --vim.g.db_ui_save_location = vim.fn.stdpath("config") .. require("plenary.path").path.sep .. "db_ui"

    vim.g.db_ui_save_location = vim.fn.expand("~/workspace/database/work/queries")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "sql",
      },
      command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
    })

    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufWinEnter", "FileType" }, {
      pattern = { "*.dbout", "dbout" },
      callback = function()
        vim.bo.readonly = false -- readonly 해제
        vim.bo.modifiable = true -- 갱신 허용
        --        vim.bo.modified = false -- 수정 플래그 초기화
      end,
    })
  end,
  keys = {
    { "<leader>Xu", "<cmd>DBUIToggle<cr>", desc = "Toggle UI" },
    { "<leader>Xf", "<cmd>DBUIFindBuffer<cr>", desc = "Find Buffer" },
    { "<leader>Xr", "<cmd>DBUIRenameBuffer<cr>", desc = "Rename Buffer" },
    { "<leader>Xq", "<cmd>DBUILastQueryInfo<cr>", desc = "Last Query Info" },
    { "<leader>Xe", "<cmd>DBUI_ExecuteQuery<cr>", desc = "Run SQL query", mode = "n" },
  },
}
