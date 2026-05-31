-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Add any additional autocmds here

-- put this in your main init.lua file ( before lazy setup )

local fn = vim.fn
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- -- Go 파일 저장 시 gofumpt 자동 실행
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.go",
--   callback = function()
--     local file = vim.fn.expand("%")
--     vim.fn.system("gofumpt -w " .. file)
--     vim.cmd("checktime")
--   end,
-- })

-- General Settings
local general = augroup("General", { clear = true })

autocmd("VimEnter", {
  callback = function(data)
    -- buffer is a directory
    local directory = vim.fn.isdirectory(data.file) == 1

    -- change to the directory
    if directory then
      vim.cmd.cd(data.file)
      vim.cmd("Telescope find_files")
      -- require("nvim-tree.api").tree.open()
    end
  end,
  group = general,
  desc = "Open Telescope when it's a Directory",
})

-- Enable Line Number in Telescope Preview
autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function()
    vim.opt_local.number = true
  end,
  group = general,
  desc = "Enable Line Number in Telescope Preview",
})

autocmd("BufReadPost", {
  callback = function()
    if fn.line("'\"") > 1 and fn.line("'\"") <= fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end,
  group = general,
  desc = "Go To The Last Cursor Position",
})

autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
  group = general,
  desc = "Highlight when yanking",
})

autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  group = general,
  desc = "Disable New Line Comment",
})

autocmd("FileType", {
  pattern = { "c", "cpp", "py", "java", "cs" },
  callback = function()
    vim.bo.shiftwidth = 4
  end,
  group = general,
  desc = "Set shiftwidth to 4 in these filetypes",
})

autocmd({ "FocusLost", "BufLeave", "BufWinLeave", "InsertLeave" }, {
  -- nested = true, -- for format on save
  callback = function()
    if vim.bo.filetype ~= "" and vim.bo.buftype == "" then
      vim.cmd("silent! w")
    end
  end,
  group = general,
  desc = "Auto Save",
})

autocmd("FocusGained", {
  callback = function()
    vim.cmd("checktime")
  end,
  group = general,
  desc = "Update file when there are changes",
})

autocmd("VimResized", {
  callback = function()
    vim.cmd("wincmd =")
  end,
  group = general,
  desc = "Equalize Splits",
})

autocmd("ModeChanged", {
  callback = function()
    if fn.getcmdtype() == "/" or fn.getcmdtype() == "?" then
      vim.opt.hlsearch = true
    else
      vim.opt.hlsearch = false
    end
  end,
  group = general,
  desc = "Highlighting matched words when searching",
})

autocmd("FileType", {
  pattern = { "gitcommit", "markdown", "text", "log" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
  group = general,
  desc = "Enable Wrap in these filetypes",
})

local overseer = augroup("Overseer", { clear = true })

autocmd("FileType", {
  pattern = "OverseerList",
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.cmd("startinsert!")
  end,
  group = overseer,
  desc = "Enter Normal Mode In OverseerList",
})

local markdown_frontmatter = augroup("MarkdownFrontmatter", { clear = true })

local function today()
  return os.date("%Y-%m-%dT%H:%M")
end

local markdown_frontmatter_dirs = {
  "~/workspace/astro-blog",
  "~/workspace/clickhouse/clickhouse-playground-book",
}

local function is_in_markdown_frontmatter_dir(path)
  local normalized_path = vim.fs.normalize(path)

  for _, dir in ipairs(markdown_frontmatter_dirs) do
    local normalized_dir = vim.fs.normalize(vim.fn.expand(dir))
    if normalized_path == normalized_dir or vim.startswith(normalized_path, normalized_dir .. "/") then
      return true
    end
  end

  return false
end

local function update_markdown_frontmatter()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" or vim.bo.buftype ~= "" then
    return
  end

  if not is_in_markdown_frontmatter_dir(path) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local date = today()

  if #lines == 0 then
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { "---", "created: " .. date, "updated: " .. date, "---", "" })
    return
  end

  if lines[1] ~= "---" then
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { "---", "created: " .. date, "updated: " .. date, "---", "" })
    return
  end

  local closing = nil
  for i = 2, math.min(#lines, 80) do
    if lines[i] == "---" then
      closing = i
      break
    end
  end

  if not closing then
    return
  end

  local created_idx = nil
  local updated_idx = nil
  for i = 2, closing - 1 do
    if lines[i]:match("^created:%s*") then
      created_idx = i
    elseif lines[i]:match("^updated:%s*") then
      updated_idx = i
    end
  end

  if created_idx then
    lines[created_idx] = lines[created_idx]:gsub("^created:%s*$", "created: " .. date)
  else
    table.insert(lines, closing, "created: " .. date)
    closing = closing + 1
  end

  if updated_idx then
    lines[updated_idx] = "updated: " .. date
  else
    table.insert(lines, closing, "updated: " .. date)
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

autocmd("BufWritePre", {
  pattern = "*.md",
  callback = update_markdown_frontmatter,
  group = markdown_frontmatter,
  desc = "Create/update Markdown frontmatter timestamps",
})
