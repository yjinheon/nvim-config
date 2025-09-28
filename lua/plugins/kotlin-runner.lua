return {
  {
    -- load local module as a "plugin"
    dir = vim.fn.stdpath("config") .. "/lua/local/kotlin-runner",
    name = "kotlin-runner",
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = "VeryLazy",
    config = function()
      require("local.kotlin-runner").setup({
        -- terminal_height = 15,
      })
    end,
  },
}
