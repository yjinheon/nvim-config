require("config.lazy")
require("luasnip/loaders/from_vscode").lazy_load()

local snip_loader = require("luasnip/loaders/from_vscode")
snip_loader.lazy_load()
snip_loader.load({ paths = { "~/.config/nvim/snippets" } })

-- set
-- vim.cmd([[
--   augroup TransparentBackground
--   autocmd!
--   autocmd ColorScheme * highlight Normal ctermbg=none guibg=none
--   autocmd ColorScheme * highlight NonText ctermbg=none guibg=none
--   augroup END
-- ]])
--
-- -- set clipboard=unnamedplus
