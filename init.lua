require("config.lazy")
require("luasnip/loaders/from_vscode").lazy_load()

local snip_loader = require("luasnip/loaders/from_vscode")
snip_loader.lazy_load()
snip_loader.load({ paths = { "~/.config/nvim/snippets" } })

-- set
-- vim.cmd([[
--   augroup TransparentBackground
--   autocmd!
--   autocmd ColorScheme * highlight Normal ctermbg=none guibg=none
--   autocmd ColorScheme * highlight NonText ctermbg=none guibg=none
--   augroup END
-- ]])
--
-- -- set clipboard=unnamedplus
-- themes : get_cursor , get_dropdown, get_ivy
function GetIncompletedTasks()
  local todo_path = "~/workspace/astro-blog/para/10.Project"
  require("telescope.builtin").grep_string(require("telescope.themes").get_ivy({
    prompt_title = "Incomplete Tasks",
    -- search = "- \\[ \\]", -- Fixed search term for tasks
    -- search = "^- \\[ \\]", -- Ensure "- [ ]" is at the beginning of the line
    search = "^\\s*- \\[ \\]", -- also match blank spaces at the beginning
    path_display = { "smart" },
    search_dirs = { todo_path }, -- Restrict search to the current working directory
    use_regex = true, -- Enable regex for the search term
    initial_mode = "normal", -- Start in normal mode
    layout_config = {
      preview_width = 0.5, -- Adjust preview width
    },
    additional_args = function()
      return { "--no-ignore" } -- Include files ignored by .gitignore
    end,
  }))
end

vim.api.nvim_create_user_command("GetIncompletedTasks", function()
  GetIncompletedTasks()
end, {})
