local Run = {}
Run.__index = Run

function Run.new(name, main_class)
  local self = setmetatable({}, Run)
  self.name = name or main_class
  self.main_class = main_class
  self.buffer = vim.api.nvim_create_buf(false, true)
  self.term_chan_id = vim.api.nvim_open_term(self.buffer, {
    on_input = function(_, _, _, data)
      self:send_job(data)
    end,
  })
  self.job_chan_id = nil
  self.is_running = false
  self.is_manually_stoped = false
  self.is_failure = false
  return self
end

function Run:start(cmd)
  local merged_cmd = table.concat(cmd, " ")
  self.is_running = true
  self:send_term(merged_cmd .. "")

  self.job_chan_id = vim.fn.jobstart(merged_cmd, {
    pty = true,
    on_stdout = function(_, data)
      if data then
        self:send_term(data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        self:send_term(data)
      end
    end,
    on_exit = function(_, exit_code)
      self:on_job_exit(exit_code)
    end,
  })
end

function Run:stop()
  if not self.job_chan_id then
    return
  end
  self.is_manually_stoped = true
  vim.fn.jobstop(self.job_chan_id)
  vim.fn.jobwait({ self.job_chan_id }, 1000)
  self.job_chan_id = nil
end

function Run:send_job(data)
  if self.job_chan_id then
    vim.fn.chansend(self.job_chan_id, data)
  end
end

function Run:send_term(data)
  vim.fn.chansend(self.term_chan_id, data)
end

function Run:on_job_exit(exit_code)
  local msg = string.format("Process finished with exit code::%s", exit_code)
  self:send_term(msg)
  self.is_running = false
  if exit_code == 0 or self.is_manually_stoped then
    self.is_failure = false
    self.is_manually_stoped = false
  else
    self.is_failure = true
    vim.notify(string.format("%s %s", self.name, msg), vim.log.levels.ERROR)
  end
end

return Run
