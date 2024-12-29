require("config.lazy")
require("luasnip/loaders/from_vscode").lazy_load()

local snip_loader = require("luasnip/loaders/from_vscode")
snip_loader.lazy_load()
snip_loader.load({ paths = { "~/.config/nvim/snippets" } })

-- -- set clipboard=unnamedplus
