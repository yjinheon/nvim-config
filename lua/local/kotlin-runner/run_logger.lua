local RunLogger = {}
RunLogger.__index = RunLogger

function RunLogger.new(cfg)
  return setmetatable({ window = -1, cfg = cfg }, RunLogger)
end

function RunLogger:create(buffer)
  if self.cfg.use_toggleterm and pcall(require, "toggleterm") then
    local Terminal = require("toggleterm.terminal").Terminal
    local term = Terminal:new({ direction = "horizontal", size = self.cfg.terminal_height, close_on_exit = false })
    term:open()
    self.window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(self.window, buffer)
  else
    vim.cmd("botright " .. self.cfg.terminal_height .. "split | buffer " .. buffer)
    self.window = vim.api.nvim_get_current_win()
  end

  vim.wo[self.window].number = false
  vim.wo[self.window].relativenumber = false
  vim.wo[self.window].signcolumn = "no"
  self:scroll_to_bottom()
end

function RunLogger:set_buffer(buffer)
  if self:is_opened() then
    vim.api.nvim_win_set_buf(self.window, buffer)
  else
    self:create(buffer)
  end
  self:scroll_to_bottom()
end

function RunLogger:scroll_to_bottom()
  if not self:is_opened() then
    return
  end
  local buffer = vim.api.nvim_win_get_buf(self.window)
  local line_count = vim.api.nvim_buf_line_count(buffer)
  vim.api.nvim_win_set_cursor(self.window, { line_count, 0 })
end

function RunLogger:is_opened()
  return self.window and vim.api.nvim_win_is_valid(self.window)
end

function RunLogger:close()
  if self:is_opened() then
    vim.api.nvim_win_hide(self.window)
  end
end

return RunLogger
