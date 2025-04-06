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

--snipe menu
map("n", "<leader>e", function()
  require("snipe").open_buffer_menu()
end, { noremap = true, silent = true })

--markdown preview

map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>")
-- toggle transparency
-- map("n", "<leader>tt", "<cmd> TransparentToggle <CR>")

map("n", "<leader>tt", ":silent !~/bash_utils/toggle_opacity.sh<CR>", { noremap = true, silent = true })
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
map("n", "<leader>.", function()
  require("Comment.api").toggle.linewise.current()
end)
map("v", "<leader>.", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>")
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
map("n", "<F3>", "<cmd> CopilotChatToggle <CR>")
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

  vim.cmd(split_size .. "split")
  vim.cmd("terminal python3 %")
end

-- F5 키에 매핑
map("n", "<F5>", function()
  vim.cmd("w") -- 파일 저장
  RunPythonInSplit()
end, { noremap = true })

-- Go 파일을 터미널에서 실행하는 함수
function RunGoInSplit()
  local win_height = vim.fn.winheight(0)
  local split_size = math.floor(win_height / 4)

  vim.cmd(split_size .. "split")
  vim.cmd("terminal go run %")
end

-- F6 키에 매핑
vim.keymap.set("n", "<F6>", function()
  vim.cmd("w") -- 파일 저장
  RunGoInSplit()
end, { noremap = true })

--map(
--  "n",
--  "<F5>",
--  ":exec '!/home/jinheonyoon/anaconda3/envs/neural-net/bin/python3' shellescape(@%, 1)<CR>",
--  { noremap = true }
--)

--map("n", "<F6>", ":w<CR>:lua RunGoFile()<CR>", { noremap = true, silent = false })
--map("n", "<F6>", ":exec '!go run' shellescape(@%, 1)<CR>", { noremap = true })
--map("n", "<F7>", ":exec '!java' shellescape(@%, 1)<CR>", { noremap = true })

-- run node js
map("n", "<F7>", "<cmd>JavaRunnerRunMain<CR>", { noremap = true })
map("n", "<F8>", ":exec '!node' shellescape(@%, 1)<CR>", { noremap = true })
-- disable copilot
map("n", "<F9>", "<cmd> Copilot disable <CR>", { noremap = true })
-- run python test method
--map("n", "<F10>", ":lua require('dap-python').test_method()", { noremap = true })
--map("n", "<F11>", ":exec '!' shellescape(@%, 1)<CR>", { noremap = true })
--map("n", "<F11>", ":exec '!kotlinr ' shellescape(@%, 1)<CR>", { noremap = true }) --map("n", "<F9>","<cmd>DapToggleBreakpoint()<CR>", { noremap = true }) remap jj to <ESC> map("i", "jj", "<ESC>")

-- Kotlin 파일을 컴파일하고 실행
function RunKotlinInSplit()
  local win_height = vim.fn.winheight(0)
  local split_size = math.floor(win_height / 4)
  local file = vim.fn.expand("%")
  vim.cmd(split_size .. "split")
  -- 커스텀 명령어 생성
  local cmd = [[
  echo "Compiling.. please wait...";
  kotlinc "]] .. file .. [[" -include-runtime -d out.jar;
  java -jar out.jar;
  rm out.jar
  ]]

  vim.cmd("terminal " .. cmd)
end

map("n", "<F11>", function()
  vim.cmd("w") -- 파일 저장
  RunKotlinInSplit()
end, { noremap = true })

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

map("i", ",s", "<ESC>", {})
map("", ",s", "<ESC>:w<CR>", {})
map("", "s,", "<ESC>:w<CR>", {})
map("", ",q", "<ESC>:bd<cr>", {})
map("", "<c-q>", "<ESC>:qa<cr>", {})

map("n", ";", ":", {})

--move window
-- map("n", "sh", "<C-w>h")
-- map("n", "sj", "<C-w>j")
-- map("n", "sk", "<C-w>k")
-- map("n", "sl", "<C-w>l")

-- Copy and Paste to clipboard
map("v", "<leader>y", '"+y', { noremap = true })
map("n", "<leader>Y", '"+yg_', { noremap = true })
map("n", "<leader>y", '"+y', { noremap = true })
map("n", "<leader>yy", '"+yy', { noremap = true })

map("n", "<leader>p", '"+p', { noremap = true })
map("n", "<leader>P", '"+P', { noremap = true })
map("v", "<leader>p", '"+p', { noremap = true })
map("v", "<leader>P", '"+P', { noremap = true })
