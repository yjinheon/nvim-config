local M = {}

function M.run_file(command, file)
  local win_height = vim.fn.winheight(0)
  local split_size = math.floor(win_height / 4)

  vim.cmd(split_size .. "split")
  vim.cmd("autocmd! TermClose <buffer> bdelete!")
  vim.cmd("terminal " .. command .. " " .. vim.fn.shellescape(file))
  vim.cmd("startinsert")
end

return M
