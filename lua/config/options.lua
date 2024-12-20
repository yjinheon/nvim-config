-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff_lsp"
--
vim.opt.conceallevel = 0
vim.g.vim_markdown_folding_disabled = 1
vim.opt.clipboard = "unnamedplus,unnamed"

-- set case insensitive searching
vim.opt.ignorecase = true

-- set python3 as the default python interpreter
vim.g.python3_host_prog = "/usr/bin/python3"

--base46

-- put this in your main init.lua file ( before lazy setup )
vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46_cache/"

-- put this after lazy setup

-- (method 1, For heavy lazyloaders)
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- (method 2, for non lazyloaders) to load all highlights at once
for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
  dofile(vim.g.base46_cache .. v)
end

-- set completition

vim.g.lazyvim_cmp = "nvim-cmp"

-- disable preselection

vim.opt.completeopt = "menuone,noselect,preview,noinsert"

-- disable pairing
vim.b.minipairs_disable = true

vim.opt.clipboard = "unnamedplus,unnamed"

-- Copy to clipboard
vim.api.nvim_set_keymap("v", "<leader>y", '"+y', { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>Y", '"+yg_', { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>y", '"+y', { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>yy", '"+yy', { noremap = true })

-- Paste from clipboard
vim.api.nvim_set_keymap("n", "<leader>p", '"+p', { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>P", '"+P', { noremap = true })
vim.api.nvim_set_keymap("v", "<leader>p", '"+p', { noremap = true })
vim.api.nvim_set_keymap("v", "<leader>P", '"+P', { noremap = true })

--# langmap
--set langmap=ㅁa,ㅠb,ㅊc,ㅇd,ㄷe,ㄹf,ㅎg,ㅗh,ㅑi,ㅓj,ㅏk,ㅣl,ㅡm,ㅜn,ㅐo,ㅔp,ㅂq,ㄱr,ㄴs,ㅅt,ㅕu,ㅍv,ㅈw,ㅌx,ㅛy,ㅋz

vim.opt.langmap =
  "ㅁa,ㅠb,ㅊc,ㅇd,ㄷe,ㄹf,ㅎg,ㅗh,ㅑi,ㅓj,ㅏk,ㅣl,ㅡm,ㅜn,ㅐo,ㅔp,ㅂq,ㄱr,ㄴs,ㅅt,ㅕu,ㅍv,ㅈw,ㅌx,ㅛy,ㅋz"

-- set highlight

-- vim.api.nvim_set_hl(0,"MyNormal" , {bg = "#000000", }
