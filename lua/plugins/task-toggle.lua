return {
  dir = vim.fn.stdpath("config") .. "/lua",
  name = "task-toggle",
  config = function()
    require("task-toggle").setup()
  end,
}
