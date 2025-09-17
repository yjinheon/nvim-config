local M = {}

-- ---- Paths ----
local cache_dir = vim.fn.stdpath("data") .. "/sql-runner"
local cmd_file = cache_dir .. "/commands.json"
local query_dir = vim.fn.expand("~/workspace/database/dw/queries")

vim.fn.mkdir(cache_dir, "p")
vim.fn.mkdir(query_dir, "p")

M.selected_command = nil

-- ---- JSON helpers ----
local function load_json(path)
  if vim.fn.filereadable(path) == 0 then
    return {}
  end
  local f = io.open(path, "r")
  if not f then
    return {}
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if ok and data then
    return data
  end
  return {}
end

-- ---- Telescope helper ----
local function telescope_select(items, title, on_select)
  local ok_pick, pickers = pcall(require, "telescope.pickers")
  local ok_find, finders = pcall(require, "telescope.finders")
  local ok_act, actions = pcall(require, "telescope.actions")
  local ok_st, action_state = pcall(require, "telescope.actions.state")
  local ok_conf, conf = pcall(require, "telescope.config")
  if not (ok_pick and ok_find and ok_act and ok_st and ok_conf) then
    vim.notify("[sql-runner] telescope.nvim is required.", vim.log.levels.ERROR)
    return
  end

  pickers
    .new({}, {
      prompt_title = title,
      finder = finders.new_table({
        results = items,
        entry_maker = function(entry)
          return { value = entry.value, display = entry.display, ordinal = entry.ordinal }
        end,
      }),
      sorter = conf.values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        local select_fn = function()
          local sel = action_state.get_selected_entry()
          if sel then
            on_select(sel.value)
          end
          actions.close(prompt_bufnr)
        end
        map("i", "<CR>", select_fn)
        map("n", "<CR>", select_fn)
        return true
      end,
    })
    :find()
end

-- ---- Window helper ----
local function find_win_by_path(abs_path)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name == abs_path then
      return win
    end
  end
  return nil
end

-- ---- Run query via stdin -> client ----
local function run_query(name, cmd, query_text)
  if not cmd or cmd == "" then
    vim.notify("[sql-runner] No command configured.", vim.log.levels.ERROR)
    return
  end

  local outfile = cache_dir .. "/sql.out"
  local abs_out = vim.fn.fnamemodify(outfile, ":p")

  local t0 = vim.loop.hrtime()
  vim.api.nvim_echo({ { "[sql-runner] Running " .. name .. " query…", "ModeMsg" } }, false, {})

  -- Example: PGPASSWORD=xxx psql -h ... -U ... -d ... -f -   (stdin)
  local result = vim.system({ vim.o.shell, "-c", cmd }, { stdin = query_text, text = true }):wait()

  if result.code ~= 0 then
    local msg = ("[sql-runner] command failed (code=%s)\n%s"):format(tostring(result.code), result.stderr or "")
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  local f = io.open(outfile, "w")
  if not f then
    vim.notify("[sql-runner] cannot open output file", vim.log.levels.ERROR)
    return
  end
  f:write(result.stdout or "")
  f:close()

  local win = find_win_by_path(abs_out)
  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd("noautocmd edit")
  else
    vim.cmd("split " .. vim.fn.fnameescape(outfile))
  end

  local ms = math.floor((vim.loop.hrtime() - t0) / 1e6)
  vim.api.nvim_echo({ { string.format("[sql-runner] %s query done in %d ms", name, ms), "ModeMsg" } }, false, {})
end

-- ---- Autoload first alias from commands.json ----
local function autoload_first_alias()
  local commands = load_json(cmd_file)
  for alias, cmd in pairs(commands) do
    M.selected_command = { alias = alias, cmd = cmd }
    break
  end
end
autoload_first_alias()

-- ---- Public API: select alias via Telescope ----
function M.select_command()
  local commands = load_json(cmd_file)
  if vim.tbl_isempty(commands) then
    vim.notify("[sql-runner] No commands in " .. cmd_file, vim.log.levels.WARN)
    return
  end
  local items = {}
  for alias, cmd in pairs(commands) do
    table.insert(items, {
      display = (M.selected_command and M.selected_command.alias == alias) and (alias .. " [current]") or alias,
      ordinal = alias,
      value = { alias = alias, cmd = cmd },
    })
  end
  telescope_select(items, "Select SQL Command", function(choice)
    M.selected_command = choice
    vim.notify(string.format('[sql-runner] Selected "%s"', choice.alias), vim.log.levels.INFO)
  end)
end

-- ---- Run: visual selection ----
function M.run_sql_selection()
  if not M.selected_command then
    vim.notify("[sql-runner] No command selected.", vim.log.levels.ERROR)
    return
  end
  local query_text = table.concat(vim.fn.getline("'<", "'>"), "\n")
  run_query("visual", M.selected_command.cmd, query_text)
end

-- ---- Run: entire buffer ----
function M.run_sql_buffer()
  if not M.selected_command then
    vim.notify("[sql-runner] No command selected.", vim.log.levels.ERROR)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  run_query("buffer", M.selected_command.cmd, table.concat(lines, "\n"))
end

-- ---- Query files workflow (~/database/work/queries) ----
local function list_sql_files()
  local pattern = query_dir .. "/**/*.sql"
  local files = vim.fn.glob(pattern, true, true)
  table.sort(files)
  return files
end

function M.save_query_file()
  vim.ui.input({ prompt = "Save as (without .sql): " }, function(name)
    if not name or name == "" then
      return
    end
    local path = query_dir .. "/" .. name .. ".sql"
    local lines = vim.fn.getline("'<", "'>")
    local f = io.open(path, "w")
    if not f then
      vim.notify("[sql-runner] Failed to save file: " .. path, vim.log.levels.ERROR)
      return
    end
    f:write(table.concat(lines, "\n"))
    f:close()
    vim.notify("[sql-runner] Saved: " .. path, vim.log.levels.INFO)
  end)
end

function M.open_query_file()
  local files = list_sql_files()
  if not files or vim.tbl_isempty(files) then
    vim.notify("[sql-runner] No .sql files in " .. query_dir, vim.log.levels.WARN)
    return
  end
  local items = {}
  for _, path in ipairs(files) do
    local disp = vim.fn.fnamemodify(path, ":~:.")
    table.insert(items, { display = disp, ordinal = disp, value = path })
  end
  telescope_select(items, "Open SQL File", function(path)
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end)
end

function M.remove_query_file()
  local files = list_sql_files()
  if not files or vim.tbl_isempty(files) then
    vim.notify("[sql-runner] No .sql files to remove.", vim.log.levels.WARN)
    return
  end
  local items = {}
  for _, path in ipairs(files) do
    local disp = vim.fn.fnamemodify(path, ":~:.")
    table.insert(items, { display = disp, ordinal = disp, value = path })
  end
  telescope_select(items, "Remove SQL File", function(path)
    local ok, err = os.remove(path)
    if ok then
      vim.notify("[sql-runner] Removed: " .. path, vim.log.levels.INFO)
    else
      vim.notify("[sql-runner] Failed: " .. (err or path), vim.log.levels.ERROR)
    end
  end)
end

-- ---- NEW: pick .sql from query_dir and RUN immediately ----
function M.run_sql_from_dir()
  if not M.selected_command then
    vim.notify("[sql-runner] No command selected.", vim.log.levels.ERROR)
    return
  end
  local files = list_sql_files()
  if not files or vim.tbl_isempty(files) then
    vim.notify("[sql-runner] No .sql files in " .. query_dir, vim.log.levels.WARN)
    return
  end
  local items = {}
  for _, path in ipairs(files) do
    local disp = vim.fn.fnamemodify(path, ":~:.")
    table.insert(items, { display = disp, ordinal = disp, value = path })
  end
  telescope_select(items, "Run SQL From Dir", function(path)
    local lines = vim.fn.readfile(path)
    local sql = table.concat(lines or {}, "\n")
    local name = vim.fn.fnamemodify(path, ":t")
    run_query(name, M.selected_command.cmd, sql)
  end)
end

return M
