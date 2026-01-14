-- Keymaps are automatically loaded on the VeryLazy t
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- shift b to open neotree
map("n", "<S-b>", "<cmd> Neotree toggle <CR>")
--vim.keymap.del("n", "<leader>l")
-- w : move forward by word
-- b : move backward by word
-- toggle lsp diagnostics

map("n", "<leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)

--markdown preview
map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>")

vim.keymap.set("n", "<leader>fd", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.expand("%:p:h"), -- directory of current buffer
  })
end, { desc = "Find files in current buffer's directory" })

-- select query

-- map(
--   "n",
--   "<leader>vr",
--   "<cmd>OpenSqlFile<CR>",
--   { silent = true, desc = "Open .sql file from queries dir", buffer = true }
-- )
-- map(
--   "n",
--   "<leader>vp",
--   "<cmd>RemoveSqlFile<CR>",
--   { silent = true, desc = "Remove .sql file from queries dir", buffer = true }
-- )

--snipe menu

-- toggle transparency
--map("n", "<leader>tt", "<cmd> TransparentToggle <CR>")
--map("n", "<leader>tt", "<cmd> TransparentToggle<CR>", { noremap = true, silent = true })

-- map("n", "<S-b>", function()
--   Snacks.picker.explorer()
-- end)
-- live_grep cwd
--map("n", "<leader>fw", LazyVim.pick("live_grep", { root = true }))
-- cycle through buffers

map("n", "<TAB>", "<cmd> bnext <CR>")
map("n", "<S-TAB>", "<cmd> bprevious <CR>")
-- close current buffer
map("n", "<leader>q", "<cmd> bd <CR>")
-- leader sr to search and replace
-- toggle comments
map("n", "<leader>m", function()
  require("Comment.api").toggle.linewise.current()
end)
map("v", "<leader>m", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>")

--- Increment / decrement

map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- delete a word backwards
map("n", "dw", "vb_d")
-- select all
map("n", "<C-a>", "gg<S-v>G")
--jumptist
map("n", "<C-m>", "<C-i>")

--split window

map("n", "<leader>sh", ":split<Return>", opts)
map("n", "<leader>sv", ":vsplit<Return>", opts)
map("n", "<leader>se", "<C-w>=", { noremap = true, desc = "equalize window" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "close current window" })

-- extra

map("i", ",s", "<ESC>", {})
map("", ",s", "<ESC>:w<CR>", {})
map("", "s,", "<ESC>:w<CR>", {})
map("", ",q", "<ESC>:bd<cr>", {})
map("", "<c-q>", "<ESC>:qa<cr>", {})

map("n", ";", ":", {})

map("n", "<leader>e", function()
  require("snipe").open_buffer_menu()
end, { noremap = true, silent = true })

-- dap toggle breakpoints
map("n", "<F1>", "<cmd> DapToggleBreakpoint <CR>")
--map("n", "<leader>dpr", function()
-- require("dap-python").test_method()
--end)

-- jumptist
-- map("n", "<leader>s", "<cmd> Telescope jumptist <CR>")
-- F4 to NoiceLast
map("n", "<F4>", "<cmd> NoiceLast <CR>")
--F3 to ChatGPT
--map("n", "<F3>", "<cmd> ChatGPT <CR>")
--map("n", "<F3>", "<cmd> CopilotChatToggle <CR>")
-- <C-c> to close ChatGPT window

-- code action
-- tiny code action
map("n", "<leader>ca", "<cmd>lua require('tiny-code-action').code_action()<CR>")
--lspsaga
--map("n", "<C-j>", "<Cmd>Lspsaga diagnostic_jump_next<CR>", opts)
map("n", "K", "<Cmd>Lspsaga hover_doc<CR>", opts)
-- map("n", "gx", "<Cmd>Lspsaga code_action<CR>", opts)
-- map("n", "gf", "<Cmd>Lspsaga lsp_finder<CR>", opts)
-- map("n", "gd", "<Cmd>Lspsaga goto_definition<CR>", opts)
-- map("n", "gp", "<Cmd>Lspsaga peek_definition<CR>", opts)
-- map("n", "gr", "<Cmd>Lspsaga rename<CR>", opts)

--- FloatermToggle
map("n", "<F12>", ":FloatermToggle aTerm<CR>", { noremap = true })
map("t", "<F12>", "<C-\\><C-n>:FloatermToggle aTerm<CR>", { noremap = true })

-- run program infile

-- Python 파일을 터미널에서 실행하는 함수

function RunPythonInSplit()
  local win_height = vim.fn.winheight(0)
  local split_size = math.floor(win_height / 4)
  -- 절대 경로 사용 (%:p 수정자)
  local file = vim.fn.expand("%:p")
  vim.cmd(split_size .. "split")
  -- 터ㅓ미널 종료 후 자동으로 버퍼 닫기 설정
  -- vim.cmd("autocmd! TermClose <buffer> bdelete!")
  -- vim.cmd("terminal python3  " .. vim.fn.shellescape(file))
  vim.cmd('terminal python3 "' .. file .. '"')
  vim.cmd("startinsert")
end

--  키에 매핑
map("n", "<F8>", function()
  vim.cmd("w") -- 파일 저장
  RunPythonInSplit()
end, { noremap = true })

-- -- Go 파일을 터미널에서 실행하는 함수
function RunGoInSplit()
  local win_height = vim.fn.winheight(0)
  local split_size = math.floor(win_height / 4)
  local file = vim.fn.expand("%:p")
  vim.cmd(split_size .. "split")
  vim.cmd("autocmd! TermClose <buffer> bdelete!")
  vim.cmd('terminal go run "' .. file .. '"')
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<F6>", function()
  vim.cmd("w")
  RunGoInSplit()
end, { noremap = true })

-- RunNodeInSplit
-- function RunNodeInSplit()
--   local win_height = vim.fn.winheight(0)
--   local split_size = math.floor(win_height / 4)
--   local file = vim.fn.expand("%:p")
--   vim.cmd(split_size .. "split")
--   vim.cmd("autocmd! TermClose <buffer> bdelete!")
--   vim.cmd('terminal node "' .. file .. '"')
--   vim.cmd("startinsert")
-- end

-- vim.keymap.set("n", "<F8>", function()
--   vim.cmd("w")
--   RunNodeInSplit()
-- end)

--map("n", "<F5>", "<cmd>python3 shellescape(@%, 1)<CR>", { noremap = true })
--map("n", "<F6>", ":w<CR>:lua RunGoFile()<CR>", { noremap = true, silent = false })
--map("n", "<F6>", ":exec '!go run' shellescape(@%, 1)<CR>", { noremap = true })
--map("n", "<F7>", ":exec '!java' shellescape(@%, 1)<CR>", { noremap = true })

-- run node js
map("n", "<F7>", "<cmd>JavaRunnerRunMain<CR>", { noremap = true })
-- map("n", "<F8>", "<cmd>KotlinRunMain<CR>", { noremap = true })
--map("n", "<F8>", ":exec '!node' shellescape(@%, 1)<CR>", { noremap = true })

-- disable copilot
--map("n", "<F9>", "<cmd> Copilot disable <CR>", { noremap = true })
-- run python test method
--map("n", "<F10>", ":lua require('dap-python').test_method()", { noremap = true })

-- vim.keymap.set("n", "<leader>dn", function()
--   require("dap-python").test_method()
-- end, { silent = true, desc = "Debug Python Test Method" })
--
-- Normal mode: debug python test class
vim.keymap.set("n", "<leader>df", function()
  require("dap-python").test_class()
end, { silent = true, desc = "Debug Python Test Class" })

-- Visual mode: debug selected python code
vim.keymap.set("v", "<leader>ds", function()
  require("dap-python").debug_selection()
end, { silent = true, desc = "Debug Python Selection" })

-- nnoremap <silent> <leader>dn :lua require('dap-python').test_method()<CR>
-- nnoremap <silent> <leader>df :lua require('dap-python').test_class()<CR>
-- vnoremap <silent> <leader>ds <ESC>:lua require('dap-python').debug_selection()<CR>
-- --map("n", "<F11>", ":exec '!' shellescape(@%, 1)<CR>", { noremap = true })
--map("n", "<F11>", ":exec '!kotlinr ' shellescape(@%, 1)<CR>", { noremap = true })

--map("n", "<F9>","<cmd>DapToggleBreakpoint()<CR>", { noremap = true }) remap jj to <ESC> map("i", "jj", "<ESC>")

function RunKotlinInSplit()
  if vim.bo.filetype ~= "kotlin" then
    print("This is not a Kotlin file.")
    return
  end

  vim.cmd("write") -- 파일 저장

  local win_height = vim.fn.winheight(0)
  local split_size = math.floor(win_height / 4)
  local file = vim.fn.expand("%:p")

  vim.cmd(split_size .. "split")
  vim.cmd("autocmd! TermClose <buffer> bdelete!")
  vim.cmd('terminal kotlinr "' .. file .. '"')
  vim.cmd("startinsert")
end

-- map("n", "<F11>", function()
--   vim.cmd("w") -- 파일 저장
--   RunKotlinInSplit()
-- end, { noremap = true })
--
--move window
-- map("n", "sh", "<C-w>h")
-- map("n", "sj", "<C-w>j")
-- map("n", "sk", "<C-w>k")
-- map("n", "sl", "<C-w>l")

-- todo list 관리를 위한 keymap

vim.keymap.set("n", "<leader>ti", function()
  local todo_path = "~/workspace/astro-blog/para/10.Project"
  require("telescope.builtin").grep_string(require("telescope.themes").get_ivy({
    prompt_title = "Incomplete Tasks",
    -- search = "- \\[ \\]", -- Fixed search term for tasks
    -- search = "^- \\[ \\]", -- Ensure "- [ ]" is at the beginning of the line
    path_display = { "smart" },
    search = "^\\s*- \\[ \\]", -- also match blank spaces at the beginning
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
end, { desc = "[P]Search for incomplete tasks" })

-- Iterate through completed tasks in telescope
vim.keymap.set("n", "<leader>tc", function()
  local todo_path = "~/workspace/astro-blog/para/10.Project"
  require("telescope.builtin").grep_string(require("telescope.themes").get_ivy({
    prompt_title = "Completed Tasks",
    -- search = [[- \[x\] `done:]], -- Regex to match the text "`- [x] `done:"
    -- search = "^- \\[x\\] `done:", -- Matches lines starting with "- [x] `done:"
    --search = "^\\s*- \\[x\\] `done:", -- also match blank spaces at the beginning
    path_display = { "smart" },
    search = "^\\s*- \\[x\\]", -- also match blank spaces at the beginning
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
end, { desc = "[P]Search for completed tasks" })

vim.api.nvim_create_user_command("FindPosts", function()
  require("fzf-lua").files({ cwd = "~/workspace/astro-blog/src/content/posts/" })
end, {})

-- Copy and Paste to clipboard
map("v", "<leader>y", '"+y', { noremap = true })
map("n", "<leader>Y", '"+yg_', { noremap = true })
map("n", "<leader>y", '"+y', { noremap = true })
map("n", "<leader>yy", '"+yy', { noremap = true })

map("n", "<leader>p", '"+p', { noremap = true })
map("n", "<leader>P", '"+P', { noremap = true })
map("v", "<leader>p", '"+p', { noremap = true })
map("v", "<leader>P", '"+P', { noremap = true })
