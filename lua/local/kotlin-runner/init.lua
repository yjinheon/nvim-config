local M = {}

M.config = {
  kotlinc_cmd = "kotlinc",
  java_cmd = "java",
  temp_dir = vim.fn.stdpath("data") .. "/kotlin-runner",
  exclude_dirs = { "build", ".gradle", ".git", "out" },
  terminal_height = 15,
  use_split = true, -- open log in bottom split
  use_toggleterm = false, -- require('toggleterm') if true
  classpath = nil, -- optional ':'-joined classpath
  extra_kotlinc_args = {},
  extra_java_args = {},
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  local runner = require("local.kotlin-runner.runner").new(M.config)

  vim.api.nvim_create_user_command("KotlinRunMain", function(params)
    runner:start_run(params.args)
  end, { nargs = "*", complete = "file" })

  vim.api.nvim_create_user_command("KotlinRunStop", function()
    runner:stop_run()
  end, {})

  vim.api.nvim_create_user_command("KotlinRunLogs", function()
    runner:toggle_open_log()
  end, {})

  vim.api.nvim_create_user_command("KotlinRunSwitch", function()
    runner:switch_log()
  end, {})

  -- expose for require('kotlin-runner').runner:...
  M.runner = runner
end

return M
