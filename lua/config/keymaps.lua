-- Keymaps are automatically loaded on the VeryLazy t
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- w : move forward by word
-- b : move backward by word

-- toggle lsp diagnostics

map("n", "<leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)

--markdown preview
map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>")

--snipe menu

-- toggle transparency
--map("n", "<leader>tt", "<cmd> TransparentToggle <CR>")
--map("n", "<leader>tt", "<cmd> TransparentToggle<CR>", { noremap = true, silent = true })

-- shift b to open neotree
map("n", "<S-b>", "<cmd> Neotree toggle <CR>")
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
map("n", "gx", "<Cmd>Lspsaga code_action<CR>", opts)
map("n", "gf", "<Cmd>Lspsaga lsp_finder<CR>", opts)
map("n", "gd", "<Cmd>Lspsaga goto_definition<CR>", opts)
map("n", "gp", "<Cmd>Lspsaga peek_definition<CR>", opts)
map("n", "gr", "<Cmd>Lspsaga rename<CR>", opts)
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
  -- 터미널 종료 후 자동으로 버퍼 닫기 설정
  vim.cmd("autocmd! TermClose <buffer> bdelete!")
  -- vim.cmd("terminal python3  " .. vim.fn.shellescape(file))
  vim.cmd('terminal python3 "' .. file .. '"')
  vim.cmd("startinsert")
end

-- F5 키에 매핑
map("n", "<F5>", function()
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

-- F6 키에 매핑
vim.keymap.set("n", "<F6>", function()
  vim.cmd("w") -- 파일 저장
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
--map("n", "<F8>", ":exec '!node' shellescape(@%, 1)<CR>", { noremap = true })
-- disable copilot
map("n", "<F9>", "<cmd> Copilot disable <CR>", { noremap = true })

-- run python test method
map("n", "<F10>", ":lua require('dap-python').test_method()", { noremap = true })

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

map("n", "<F11>", function()
  vim.cmd("w") -- 파일 저장
  RunKotlinInSplit()
end, { noremap = true })

--move window
-- map("n", "sh", "<C-w>h")
-- map("n", "sj", "<C-w>j")
-- map("n", "sk", "<C-w>k")
-- map("n", "sl", "<C-w>l")

-- todolist 관리를 위한 keymap

vim.keymap.set("n", "<leader>ti", function()
  local todo_path = "~/workspace/astro-blog/para/10.Project"
  require("telescope.builtin").grep_string(require("telescope.themes").get_ivy({
    prompt_title = "Incomplete Tasks",
    -- search = "- \\[ \\]", -- Fixed search term for tasks
    -- search = "^- \\[ \\]", -- Ensure "- [ ]" is at the beginning of the line
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

-- Iterate through completed tasks in telescope lamw25wmal
vim.keymap.set("n", "<leader>tc", function()
  local todo_path = "~/workspace/astro-blog/para/10.Project"
  require("telescope.builtin").grep_string(require("telescope.themes").get_ivy({
    prompt_title = "Completed Tasks",
    -- search = [[- \[x\] `done:]], -- Regex to match the text "`- [x] `done:"
    -- search = "^- \\[x\\] `done:", -- Matches lines starting with "- [x] `done:"
    --search = "^\\s*- \\[x\\] `done:", -- also match blank spaces at the beginning

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

vim.keymap.set("n", "<F3>", function()
  -- Customizable variables
  -- NOTE: Customize the completion label
  local label_done = "done:"
  -- NOTE: Customize the timestamp format
  --local timestamp = os.date("%y%m%d-%H%M")
  local timestamp = os.date("%y%m%d")
  -- NOTE: Customize the heading and its level
  local tasks_heading = "## Completed tasks"
  -- Save the view to preserve folds
  vim.cmd("mkview")
  local api = vim.api
  -- Retrieve buffer & lines
  local buf = api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local start_line = cursor_pos[1] - 1
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local total_lines = #lines
  -- If cursor is beyond last line, do nothing
  if start_line >= total_lines then
    vim.cmd("loadview")
    return
  end
  ------------------------------------------------------------------------------
  -- (A) Move upwards to find the bullet line (if user is somewhere in the chunk)
  ------------------------------------------------------------------------------
  while start_line > 0 do
    local line_text = lines[start_line + 1]
    -- Stop if we find a blank line or a bullet line
    if line_text == "" or line_text:match("^%s*%-") then
      break
    end
    start_line = start_line - 1
  end
  -- Now we might be on a blank line or a bullet line
  if lines[start_line + 1] == "" and start_line < (total_lines - 1) then
    start_line = start_line + 1
  end
  ------------------------------------------------------------------------------
  -- (B) Validate that it's actually a task bullet, i.e. '- [ ]' or '- [x]'
  ------------------------------------------------------------------------------
  local bullet_line = lines[start_line + 1]
  if not bullet_line:match("^%s*%- %[[x ]%]") then
    -- Not a task bullet => show a message and return
    print("Not a task bullet: no action taken.")
    vim.cmd("loadview")
    return
  end
  ------------------------------------------------------------------------------
  -- 1. Identify the chunk boundaries
  ------------------------------------------------------------------------------
  local chunk_start = start_line
  local chunk_end = start_line
  while chunk_end + 1 < total_lines do
    local next_line = lines[chunk_end + 2]
    if next_line == "" or next_line:match("^%s*%-") then
      break
    end
    chunk_end = chunk_end + 1
  end
  -- Collect the chunk lines
  local chunk = {}
  for i = chunk_start, chunk_end do
    table.insert(chunk, lines[i + 1])
  end
  ------------------------------------------------------------------------------
  -- 2. Check if chunk has [done: ...] or [untoggled], then transform them
  ------------------------------------------------------------------------------
  local has_done_index = nil
  local has_untoggled_index = nil
  for i, line in ipairs(chunk) do
    -- Replace `[done: ...]` -> `` `done: ...` ``
    chunk[i] = line:gsub("%[done:([^%]]+)%]", "`" .. label_done .. "%1`")
    -- Replace `[untoggled]` -> `` `untoggled` ``
    chunk[i] = chunk[i]:gsub("%[untoggled%]", "`untoggled`")
    if chunk[i]:match("`" .. label_done .. ".-`") then
      has_done_index = i
      break
    end
  end
  if not has_done_index then
    for i, line in ipairs(chunk) do
      if line:match("`untoggled`") then
        has_untoggled_index = i
        break
      end
    end
  end
  ------------------------------------------------------------------------------
  -- 3. Helpers to toggle bullet
  ------------------------------------------------------------------------------
  -- Convert '- [ ]' to '- [x]'
  local function bulletToX(line)
    return line:gsub("^(%s*%- )%[%s*%]", "%1[x]")
  end
  -- Convert '- [x]' to '- [ ]'
  local function bulletToBlank(line)
    return line:gsub("^(%s*%- )%[x%]", "%1[ ]")
  end
  ------------------------------------------------------------------------------
  -- 4. Insert or remove label *after* the bracket
  ------------------------------------------------------------------------------
  local function insertLabelAfterBracket(line, label)
    local prefix = line:match("^(%s*%- %[[x ]%])")
    if not prefix then
      return line
    end
    local rest = line:sub(#prefix + 1)
    return prefix .. " " .. label .. rest
  end
  local function removeLabel(line)
    -- If there's a label (like `` `done: ...` `` or `` `untoggled` ``) right after
    -- '- [x]' or '- [ ]', remove it
    return line:gsub("^(%s*%- %[[x ]%])%s+`.-`", "%1")
  end
  ------------------------------------------------------------------------------
  -- 5. Update the buffer with new chunk lines (in place)
  ------------------------------------------------------------------------------
  local function updateBufferWithChunk(new_chunk)
    for idx = chunk_start, chunk_end do
      lines[idx + 1] = new_chunk[idx - chunk_start + 1]
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end
  ------------------------------------------------------------------------------
  -- 6. Main toggle logic
  ------------------------------------------------------------------------------
  if has_done_index then
    chunk[has_done_index] = removeLabel(chunk[has_done_index]):gsub("`" .. label_done .. ".-`", "`untoggled`")
    chunk[1] = bulletToBlank(chunk[1])
    chunk[1] = removeLabel(chunk[1])
    chunk[1] = insertLabelAfterBracket(chunk[1], "`untoggled`")
    updateBufferWithChunk(chunk)
    vim.notify("Untoggled", vim.log.levels.INFO)
  elseif has_untoggled_index then
    chunk[has_untoggled_index] =
      removeLabel(chunk[has_untoggled_index]):gsub("`untoggled`", "`" .. label_done .. " " .. timestamp .. "`")
    chunk[1] = bulletToX(chunk[1])
    chunk[1] = removeLabel(chunk[1])
    chunk[1] = insertLabelAfterBracket(chunk[1], "`" .. label_done .. " " .. timestamp .. "`")
    updateBufferWithChunk(chunk)
    vim.notify("Completed", vim.log.levels.INFO)
  else
    -- Save original window view before modifications
    local win = api.nvim_get_current_win()
    local view = api.nvim_win_call(win, function()
      return vim.fn.winsaveview()
    end)
    chunk[1] = bulletToX(chunk[1])
    chunk[1] = insertLabelAfterBracket(chunk[1], "`" .. label_done .. " " .. timestamp .. "`")
    -- Remove chunk from the original lines
    for i = chunk_end, chunk_start, -1 do
      table.remove(lines, i + 1)
    end
    -- Append chunk under 'tasks_heading'
    local heading_index = nil
    for i, line in ipairs(lines) do
      if line:match("^" .. tasks_heading) then
        heading_index = i
        break
      end
    end
    if heading_index then
      for _, cLine in ipairs(chunk) do
        table.insert(lines, heading_index + 1, cLine)
        heading_index = heading_index + 1
      end
      -- Remove any blank line right after newly inserted chunk
      local after_last_item = heading_index + 1
      if lines[after_last_item] == "" then
        table.remove(lines, after_last_item)
      end
    else
      table.insert(lines, tasks_heading)
      for _, cLine in ipairs(chunk) do
        table.insert(lines, cLine)
      end
      local after_last_item = #lines + 1
      if lines[after_last_item] == "" then
        table.remove(lines, after_last_item)
      end
    end
    -- Update buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.notify("Completed", vim.log.levels.INFO)
    -- Restore window view to preserve scroll position
    api.nvim_win_call(win, function()
      vim.fn.winrestview(view)
    end)
  end
  -- Write changes and restore view to preserve folds
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd("silent update")
  vim.cmd("loadview")
end, { desc = "[P]Toggle task and move it to 'done'" })

-- Crate task or checkbox
-- These are marked with <leader>x using bullets.vim
vim.keymap.set({ "n", "i" }, "<F2>", function()
  -- Get the current line and cursor position
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  -- Check if the line starts with a bullet or "- ", and remove it
  local updated_line = line:gsub("^%s*[-*]%s*", "", 1)
  -- Update the line
  vim.api.nvim_set_current_line(updated_line)
  -- Move the cursor back to its original position
  vim.api.nvim_win_set_cursor(0, { cursor[1], #updated_line })
  -- Insert the checkbox
  vim.api.nvim_put({ "- [ ] #todo " }, "c", true, true)
end, { desc = "[P]Toggle checkbox" })

-- Copy and Paste to clipboard
map("v", "<leader>y", '"+y', { noremap = true })
map("n", "<leader>Y", '"+yg_', { noremap = true })
map("n", "<leader>y", '"+y', { noremap = true })
map("n", "<leader>yy", '"+yy', { noremap = true })

map("n", "<leader>p", '"+p', { noremap = true })
map("n", "<leader>P", '"+P', { noremap = true })
map("v", "<leader>p", '"+p', { noremap = true })
map("v", "<leader>P", '"+P', { noremap = true })
