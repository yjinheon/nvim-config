require("config.lazy")
require("luasnip/loaders/from_vscode").lazy_load()

local snip_loader = require("luasnip/loaders/from_vscode")
snip_loader.lazy_load()
snip_loader.load({ paths = { "~/.config/nvim/snippets" } })

--local telescope = require("telescope")
--telescope.load_extension("vim-dadbod-dbselect")
-- set clipboard=unnamedplus
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

-- simple FindAndAdd
vim.api.nvim_create_user_command("FindAndAdd", function(opts)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- file creation
  local function create_file(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    actions.close(prompt_bufnr)

    vim.ui.input({ prompt = "New file: " }, function(input)
      if input and input ~= "" then
        local base_dir = picker.cwd or vim.fn.getcwd()
        local filepath = vim.fs.joinpath(base_dir, input)

        -- 디렉토리가 없으면 생성
        local dir = vim.fn.fnamemodify(filepath, ":h")
        if vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, "p")
        end

        vim.cmd("edit " .. vim.fn.fnameescape(filepath))
      end
    end)
  end

  -- telescope 옵션
  local telescope_opts = {
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(actions.select_default)

      -- 파일 생성 매핑만 추가
      map("n", "<C-f>", create_file)
      map("i", "<C-f>", create_file)

      return true
    end,
  }

  -- 디렉토리 인자 처리
  if opts.args and opts.args ~= "" then
    telescope_opts.cwd = vim.fn.expand(opts.args)
  end

  require("telescope.builtin").find_files(telescope_opts)
end, {
  desc = "Find files with create option",
  nargs = "?",
  complete = "dir",
})

vim.keymap.set("n", "<leader>fa", ":FindAndAdd<CR>", { desc = "Find/Add files" })
