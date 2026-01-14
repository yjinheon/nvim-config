-- Task Toggle Module for Neovim
local M = {}

M.config = {
  -- 날짜 형식
  date_format = "%Y-%m-%d",

  -- Task 속성 키 (Obsidian Tasks 스타일)
  keys = {
    due = "due",
    completion = "completion",
  },

  -- 기본 태그
  default_tag = "#todo",

  -- 완료된 task 이동할 헤딩 (nil이면 이동 안함)
  completed_heading = "## Completed tasks",

  -- 체크박스 패턴
  patterns = {
    unchecked = "- [ ]",
    checked = "- [x]",
  },
}

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

-- 속성값 추출: [key:: value] 형태에서 value 반환
local function get_property(text, key)
  local pattern = "%[" .. key .. "::([^%]]+)%]"
  local value = text:match(pattern)
  return value and vim.trim(value) or nil
end

-- 속성값 설정/추가: 기존 값이 있으면 교체, 없으면 끝에 추가
local function set_property(text, key, value)
  local pattern = "%[" .. key .. "::[^%]]*%]"
  local new_prop = "[" .. key .. ":: " .. value .. "]"

  if text:match(pattern) then
    return text:gsub(pattern, new_prop)
  else
    -- 줄 끝 공백 제거 후 추가
    return vim.trim(text) .. "  " .. new_prop
  end
end

-- 속성값 제거
local function remove_property(text, key)
  local pattern = "%s*%[" .. key .. "::[^%]]*%]"
  return text:gsub(pattern, "")
end

-- Task bullet 여부 확인
local function is_task_bullet(line)
  if not line or line == "" then
    return false
  end
  return line:match("^%s*[%-%*%+]%s*%[.-%]") ~= nil
end

-- 체크박스 상태 확인
local function is_checked(line)
  return line:match("^%s*[%-%*%+]%s*%[[xX]%]") ~= nil
end

-- 체크박스 토글
local function toggle_checkbox(line, to_checked)
  if to_checked then
    return line:gsub("^(%s*[%-%*%+]%s*)%[[ ]%]", "%1[x]")
  else
    return line:gsub("^(%s*[%-%*%+]%s*)%[[xX]%]", "%1[ ]")
  end
end

-- Chunk 경계 찾기 (bullet line + 이어지는 continuation lines)
local function find_chunk_boundaries(lines, start_line)
  local total = #lines

  -- 위로 이동해서 bullet line 찾기
  while start_line > 0 do
    local line_text = lines[start_line + 1]
    if line_text == "" or line_text:match("^%s*%-") then
      break
    end
    start_line = start_line - 1
  end

  -- 빈 줄이면 다음 줄로
  if lines[start_line + 1] == "" and start_line < (total - 1) then
    start_line = start_line + 1
  end

  -- Chunk 끝 찾기
  local chunk_start = start_line
  local chunk_end = start_line

  while chunk_end + 1 < total do
    local next_line = lines[chunk_end + 2]
    if next_line == "" or next_line:match("^%s*%-") then
      break
    end
    chunk_end = chunk_end + 1
  end

  return chunk_start, chunk_end
end

-- Heading 위치 찾기
local function find_heading_index(lines, heading)
  for i, line in ipairs(lines) do
    if line:match("^" .. vim.pesc(heading)) then
      return i
    end
  end
  return nil
end

--------------------------------------------------------------------------------
-- Main Functions
--------------------------------------------------------------------------------

-- F10: 새 Task 생성
function M.create_task()
  local cfg = M.config
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)

  -- 기존 bullet 제거
  local updated_line = line:gsub("^%s*[-*]%s*", "", 1)
  local date_str = os.date(cfg.date_format)

  -- 새 task 형식
  local new_task = cfg.patterns.unchecked .. " " .. cfg.default_tag .. " [" .. cfg.keys.due .. ":: " .. date_str .. "]"

  vim.api.nvim_set_current_line(updated_line)
  vim.api.nvim_win_set_cursor(0, { cursor[1], #updated_line })
  vim.api.nvim_put({ new_task }, "c", true, true)
end

-- F11: Task 완료 토글
function M.toggle_complete()
  local cfg = M.config
  local api = vim.api
  local buf = api.nvim_get_current_buf()
  local cursor_pos = api.nvim_win_get_cursor(0)
  local start_line = cursor_pos[1] - 1
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local total_lines = #lines

  if start_line >= total_lines then
    return
  end

  -- View 저장 (fold 유지)
  vim.cmd("mkview")

  -- Chunk 경계 찾기
  local chunk_start, chunk_end = find_chunk_boundaries(lines, start_line)
  local bullet_line = lines[chunk_start + 1]

  -- Task bullet 확인
  if not is_task_bullet(bullet_line) then
    vim.notify("Not a task bullet", vim.log.levels.WARN)
    vim.cmd("loadview")
    return
  end

  -- Chunk 추출
  local chunk = {}
  for i = chunk_start, chunk_end do
    table.insert(chunk, lines[i + 1])
  end

  local date_str = os.date(cfg.date_format)
  local currently_checked = is_checked(chunk[1])

  if currently_checked then
    -- 완료 → 미완료로 토글
    chunk[1] = toggle_checkbox(chunk[1], false)
    chunk[1] = remove_property(chunk[1], cfg.keys.completion)
    vim.notify("Uncompleted", vim.log.levels.INFO)

    -- 버퍼 업데이트 (제자리)
    for idx = chunk_start, chunk_end do
      lines[idx + 1] = chunk[idx - chunk_start + 1]
    end
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  else
    -- 미완료 → 완료로 토글
    local win = api.nvim_get_current_win()
    local view = api.nvim_win_call(win, function()
      return vim.fn.winsaveview()
    end)

    chunk[1] = toggle_checkbox(chunk[1], true)
    chunk[1] = set_property(chunk[1], cfg.keys.completion, date_str)

    -- 원래 위치에서 chunk 제거
    for i = chunk_end, chunk_start, -1 do
      table.remove(lines, i + 1)
    end

    -- Completed heading 아래로 이동
    if cfg.completed_heading then
      local heading_idx = find_heading_index(lines, cfg.completed_heading)

      if heading_idx then
        for _, cLine in ipairs(chunk) do
          table.insert(lines, heading_idx + 1, cLine)
          heading_idx = heading_idx + 1
        end
        -- 빈 줄 제거
        if lines[heading_idx + 1] == "" then
          table.remove(lines, heading_idx + 1)
        end
      else
        -- Heading 없으면 생성
        table.insert(lines, cfg.completed_heading)
        for _, cLine in ipairs(chunk) do
          table.insert(lines, cLine)
        end
      end
    else
      -- 이동 안하고 제자리 업데이트
      for idx = chunk_start, chunk_end do
        lines[idx + 1] = chunk[idx - chunk_start + 1]
      end
    end

    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.notify("Completed", vim.log.levels.INFO)

    api.nvim_win_call(win, function()
      vim.fn.winrestview(view)
    end)
  end

  vim.cmd("silent update")
  vim.cmd("loadview")
end

--------------------------------------------------------------------------------
-- Keymap Setup
--------------------------------------------------------------------------------

function M.setup(opts)
  -- 사용자 설정 병합
  if opts then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end

  vim.keymap.set({ "n", "i" }, "<F10>", M.create_task, { desc = "[P] Create new task" })

  vim.keymap.set("n", "<F11>", M.toggle_complete, { desc = "[P] Toggle task completion" })
end

return M
