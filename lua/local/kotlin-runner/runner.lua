-- kotlin-runner/runner.lua
-- Orchestrates finding main files, building commands, and wiring Run + Logger (Gradle-integrated)

local Runner = {}
Runner.__index = Runner

local function file_exists(p)
  local st = vim.loop.fs_stat(p)
  return st ~= nil and st.type == "file"
end

local function exists(path)
  return vim.loop.fs_stat(path) ~= nil
end

local function ensure_tmp(dir)
  if not exists(dir) then
    vim.fn.mkdir(dir, "p")
  end
end

local function current_buf_dir()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if not name or name == "" then
    return vim.fn.getcwd()
  end
  return vim.fn.fnamemodify(name, ":p:h")
end

local function project_root()
  -- Prefer nearest build markers from the **current buffer** path, then git root, then CWD
  local start = current_buf_dir()
  local markers = { "gradlew", "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts", ".git" }
  local found = vim.fs.find(markers, { upward = true, path = start })[1]
  if found then
    local root = vim.fn.fnamemodify(found, ":p:h")
    return root
  end
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if git_root and #git_root > 0 and git_root:match("^/") then
    return git_root
  end
  return vim.fn.getcwd()
end

local function read_file(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local s = fd:read("*a")
  fd:close()
  return s
end

local function rg_available()
  return vim.fn.executable("rg") == 1
end

-- ripgrep로 main() 찾기
local function find_mains(root, exclude_dirs)
  local files = {}

  if rg_available() then
    local cmd = {
      "rg",
      "--no-heading",
      "--line-number",
      "--color",
      "never",
      "--hidden",
      "--follow",
    }
    -- 제외 디렉토리
    for _, ex in ipairs(exclude_dirs or {}) do
      table.insert(cmd, "-g")
      table.insert(cmd, "!**/" .. ex .. "/**")
    end
    -- 포함 글롭 (src 우선 + 전체)
    table.insert(cmd, "-g")
    table.insert(cmd, "src/**/*.kt")
    table.insert(cmd, "-g")
    table.insert(cmd, "**/*.kt")

    -- 느슨한 main 패턴들 (※ Lua->rg로 literal 백슬래시 전달하려면 \\ 사용)
    table.insert(cmd, "-e")
    table.insert(cmd, "fun\\s+main\\s*\\(") -- 일반 main
    table.insert(cmd, "-e")
    table.insert(cmd, "@JvmStatic\\s+fun\\s+main\\s*\\(") -- object static main
    table.insert(cmd, "-e")
    table.insert(cmd, "suspend\\s+fun\\s+main\\s*\\(") -- suspend main

    -- 검색 루트
    table.insert(cmd, root)

    local lines = vim.fn.systemlist(cmd)
    for _, line in ipairs(lines) do
      -- path:line:... 형태에서 path만 추출
      local path = line:match("^(.-):%d+:") or line:match("^(.-):%d+") or line
      if path and path:match("%.kt$") then
        files[path] = true
      end
    end
  else
    -- ripgrep 없을 때 폴백 (Lua 패턴)
    local kt_files = vim.fn.globpath(root, "src/**/*.kt", true, true)
    if #kt_files == 0 then
      kt_files = vim.fn.globpath(root, "**/*.kt", true, true)
    end
    for _, f in ipairs(kt_files) do
      local skip = false
      for _, ex in ipairs(exclude_dirs or {}) do
        if f:find("/" .. ex .. "/") then
          skip = true
          break
        end
      end
      if not skip then
        local txt = read_file(f)
        if
          txt
          and (
            txt:match("@JvmStatic%s+fun%s+main%s*%(")
            or txt:match("suspend%s+fun%s+main%s*%(")
            or txt:match("fun%s+main%s*%(")
          )
        then
          files[f] = true
        end
      end
    end
  end

  local list = {}
  for f, _ in pairs(files) do
    table.insert(list, f)
  end
  table.sort(list)

  vim.notify(string.format("[kotlin-runner] root=%s, found %d main file(s)", root, #list))
  return list
end

-- FQCN 추정 (package / object { @JvmStatic fun main } / top-level main)
local function parse_pkg_and_mainclass(filepath)
  local content = read_file(filepath) or ""

  -- 라인 선두 공백 허용, 또는 아무 곳에서라도 package 선언 찾기
  local pkg = content:match("^%s*package%s+([%a_][%w_%.]*)")
    or content:match("[\r\n]%s*package%s+([%a_][%w_%.]*)")
    or ""

  -- main 이전 구간에서 가장 가까운 object 이름을 찾는다
  local main_pos = content:find("fun%s+main%s*%(")
  local obj_name
  if main_pos then
    local window = content:sub(1, main_pos)
    for name in window:gmatch("object%s+([%a_][%w_]*)") do
      obj_name = name -- 마지막 = 가장 가까운 object
    end
  end

  local fname = vim.fn.fnamemodify(filepath, ":t:r")
  local class_name = obj_name or (fname .. "Kt")

  if pkg ~= "" then
    return pkg .. "." .. class_name
  else
    return class_name
  end
end

local function choose_gradle_task(root)
  -- Heuristic: prefer bootRun if Spring Boot is applied, else run if application plugin present
  local build_paths = {
    root .. "/build.gradle",
    root .. "/build.gradle.kts",
    root .. "/settings.gradle",
    root .. "/settings.gradle.kts",
  }
  local blob = ""
  for _, p in ipairs(build_paths) do
    local s = read_file(p)
    if s then
      blob = blob .. "" .. s
    end
  end
  if blob:find("org%.springframework%.boot") then
    --return "bootRun"
    return "run" -- spring boot project여도 그냥 run이 맞음
  end
  if
    blob:find("plugins?%s*{[%w%p%s]-application")
    or blob:find('apply%s+plugin%s*:%s*"application"')
    or blob:find("application%s*{")
  then
    return "run"
  end
  return "run"
end

local function gradle_exe(root)
  if file_exists(root .. "/gradlew") then
    return "./gradlew"
  end
  if file_exists(root .. "/gradlew.bat") then
    return "gradlew.bat"
  end
  return "gradle"
end

local function shell_escape(s)
  if not s or #s == 0 then
    return ""
  end
  return string.format("'%s'", s:gsub("'", "'''"))
end

local function build_gradle_command(root, fqcn, program_args)
  local task = choose_gradle_task(root)
  local g = gradle_exe(root)
  local args_str = table.concat(program_args or {}, " ")
  local has_args = (args_str ~= nil and #args_str > 0)

  local cmd = { "cd", shell_escape(root), "&&", g, "-q", task }
  if has_args then
    table.insert(cmd, string.format("--args=%s", shell_escape(args_str)))
  end
  if fqcn and #fqcn > 0 then
    table.insert(cmd, string.format("-PmainClass=%s", shell_escape(fqcn)))
  end
  table.insert(cmd, "--no-daemon")
  return table.concat(cmd, " ")
end

local function open_picker(paths, root, on_select)
  if pcall(require, "telescope") then
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local themes = require("telescope.themes")
    local entry_display = require("telescope.pickers.entry_display")

    local displayer = entry_display.create({
      separator = "",
      items = {
        { width = 999 },
      },
    })

    local opts = themes.get_dropdown({
      prompt_title = "kotlin mains(Gradle)",
      previewer = false,
      winbind = 10,
      layout_config = {
        width = 0.5,
        height = 0.4,
      },
    })

    pickers
      .new(opts, {
        prompt_title = "Kotlin mains (Gradle)",
        finder = finders.new_table({
          results = paths,
          entry_maker = function(path)
            -- absolute path에서 root 제거하고 src/kotlin 이후만 표시
            local rel_path = path:gsub("^" .. vim.pesc(root) .. "/", "")
            local display_path = rel_path:match("(src/kotlin/.+)") or rel_path
            return {
              value = path,
              display = function()
                return displayer({ display_path })
              end,
              ordinal = display_path,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(_, map)
          map("i", "<CR>", function(prompt_bufnr)
            local action_state = require("telescope.actions.state")
            local sel = action_state.get_selected_entry()
            require("telescope.actions").close(prompt_bufnr)
            on_select(sel.value)
          end)
          return true
        end,
      })
      :find()
  else
    vim.ui.select(paths, { prompt = "Select Kotlin main file" }, function(choice)
      if choice then
        on_select(choice)
      end
    end)
  end
end

function Runner.new(cfg)
  local self = setmetatable({}, Runner)
  self.cfg = cfg
  self.runs = {} -- main_class -> Run
  self.curr_run = nil
  self.logger = require("local.kotlin-runner.run_logger").new(cfg)
  return self
end

function Runner:start_run(args)
  local root = project_root()
  local mains = find_mains(root, self.cfg.exclude_dirs)
  if #mains == 0 then
    vim.notify("No Kotlin main() found under " .. root, vim.log.levels.WARN)
    return
  end
  -- split user args by spaces like a shell (simple heuristic)
  local program_args = {}
  if args and #args > 0 then
    for a in string.gmatch(args, "[^%s]+") do
      table.insert(program_args, a)
    end
  end

  local function launch(filepath)
    local fq = parse_pkg_and_mainclass(filepath)
    local name = string.format("%s -> %s", vim.fn.fnamemodify(filepath, ":."), fq)

    local run = self.runs[fq]
    if run and run.is_running then
      run:stop()
    end
    if not run then
      run = require("local.kotlin-runner.run").new(name, fq)
      self.runs[fq] = run
    end

    self.curr_run = run
    self.logger:set_buffer(run.buffer)

    local gradle_cmd = build_gradle_command(root, fq, program_args)
    local banner = string.format("echo '[kotlin-runner] %s'", gradle_cmd)
    run:start({ "sh", "-lc", banner .. " && " .. gradle_cmd })
  end

  if #mains == 1 then
    launch(mains[1])
  else
    open_picker(mains, root, launch)
  end
end

function Runner:stop_run()
  local keys = {}
  for k, _ in pairs(self.runs) do
    table.insert(keys, k)
  end
  table.sort(keys)

  local function pick_and_stop(main)
    local run = self.runs[main]
    if run then
      run:stop()
    end
  end

  if #keys == 0 then
    return
  end
  if #keys == 1 then
    pick_and_stop(keys[1])
  else
    vim.ui.select(keys, { prompt = "Select run to stop" }, function(choice)
      if choice then
        pick_and_stop(choice)
      end
    end)
  end
end

function Runner:toggle_open_log()
  if self.logger:is_opened() then
    self.logger:close()
  else
    if self.curr_run then
      self.logger:create(self.curr_run.buffer)
    end
  end
end

function Runner:switch_log()
  local keys = {}
  for k, _ in pairs(self.runs) do
    table.insert(keys, k)
  end
  table.sort(keys)
  if #keys == 0 then
    return
  end
  local function pick_and_switch(main)
    self.curr_run = self.runs[main]
    if self.curr_run then
      self.logger:set_buffer(self.curr_run.buffer)
    end
  end
  if #keys == 1 then
    pick_and_switch(keys[1])
  else
    vim.ui.select(keys, { prompt = "Select run to show" }, function(choice)
      if choice then
        pick_and_switch(choice)
      end
    end)
  end
end

return Runner
