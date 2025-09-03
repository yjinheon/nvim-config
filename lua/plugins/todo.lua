return {

  "bngarren/checkmate.nvim",
  ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
  opts = {
    -- your configuration here
    -- or leave empty to use defaults
    files = { "tasks", "*.plan", "project/**/todo.md", "todo.md" },
    todo_markers = {
      unchecked = "[ ]",
      checked = "[x]",
    },
  },
}
