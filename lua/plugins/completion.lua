return {
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require("cmp")

      -- Markdown 파일에 대해서만 별도 설정 적용
      cmp.setup.filetype("markdown", {
        sources = cmp.config.sources({
          -- 스니펫(luasnip)을 제외
          { name = "nvim_lsp" }, -- LSP 추천 (헤더 링크 등)
          { name = "path" }, -- 파일 경로 자동완성
          { name = "buffer" }, -- 현재 버퍼 내 단어 추천
        }),
      })
      -- local lspkind = require("lspkind")
      --
      -- opts.formatting = {
      --   format = lspkind.cmp_format({
      --     mode = "symbol_text", -- show only symbol annotations
      --     --            preset = "codicons",
      --     maxwidth = {
      --       -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      --       -- can also be a function to dynamically calculate max width such as
      --       -- menu = function() return math.floor(0.45 * vim.o.columns) end,
      --       menu = 50, -- leading text (labelDetails)
      --       abbr = 50, -- actual suggestion item
      --     },
      --     ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      --     show_labelDetails = false, -- show labelDetails in menu. Disabled by default
      --
      --     -- The function below will be called before any actual modifications from lspkind
      --     -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      --     before = function(entry, vim_item)
      --       -- ...
      --       return vim_item
      --     end,
      --   }),
      --}

      opts.completion = {
        --completeopt = "menu,menuone,noinsert,noselect",
        completeopt = "menu,menuone,noinsert,noselect",
        --autocomplete = false,
      }

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-y>"] = cmp.mapping.confirm({ select = false }),
        --          ["CR"] = cmp.config.disable,
        --          ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<CR>"] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = false }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
        }),
        ["<S-CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

        ["<Tab>"] = { -- see GH-880, GH-897
          i = function(fallback) -- see GH-231, GH-286
            if cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end,
        },
        ["<S-Tab>"] = {
          i = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,
        },
      })
    end,
  },
}
