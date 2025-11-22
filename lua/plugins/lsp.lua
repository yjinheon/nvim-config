return {
  -- Lspsaga
  {
    "nvimdev/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({
        ui = {
          enable = false,
          sign = false,
          code_action = "",
        },
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  {
    "rachartier/tiny-code-action.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },

      -- optional picker via telescope
      { "nvim-telescope/telescope.nvim" },
      -- optional picker via fzf-lua
      { "ibhagwan/fzf-lua" },
      -- .. or via snacks
      {
        "folke/snacks.nvim",
        opts = {
          terminal = {},
        },
      },
    },
    event = "LspAttach",
    opts = {
      picker = "fzf-lua",
    },
  },

  -- LSP Core
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", config = true },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      {
        "j-hui/fidget.nvim",
        opts = { notification = { window = { winblend = 0 } } },
      },
      "hrsh7th/cmp-nvim-lsp",
    },

    config = function()
      -- LspAttach: Lspsaga 기반 키맵
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        -- LazyVim 기본 'K' 매핑 제거 (버퍼 로컬 + 혹시 모를 글로벌)

        callback = function(event)
          pcall(vim.keymap.del, "n", "K", { buffer = event.buf })
          pcall(vim.keymap.del, "n", "K")
          local map = function(keys, rhs, desc)
            vim.keymap.set("n", keys, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          local ok_tb, tb = pcall(require, "telescope.builtin")

          map("gd", "<cmd>Lspsaga goto_definition<CR>", "[G]oto [D]efinition")
          map("gp", "<cmd>Lspsaga peek_definition<CR>", "Pe[e]k Definition")
          map("gr", "<cmd>Lspsaga finder<CR>", "[G]oto [R]eferences (Finder)")
          map("gI", "<cmd>Lspsaga finder<CR>", "[G]oto [I]mplementations (Finder)")
          map("<leader>D", "<cmd>Lspsaga goto_type_definition<CR>", "Type [D]efinition")

          map("<leader>ds", "<cmd>Lspsaga outline<CR>", "[D]ocument [S]ymbols (Outline)")
          if ok_tb then
            map("<leader>ws", tb.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
          else
            map("<leader>ws", "<cmd>Lspsaga outline<CR>", "[W]orkspace [S]ymbols (Outline)")
          end

          map("<leader>rn", "<cmd>Lspsaga rename<CR>", "[R]e[n]ame")
          --map("<leader>ca", "<cmd>Lspsaga code_action<CR>", "[C]ode [A]ction")
          map("K", "<cmd>Lspsaga hover_doc<CR>", "Hover Documentation")

          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          map("]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", "Next Diagnostic")
          map("[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Prev Diagnostic")
          map("<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", "Cursor Diagnostics")

          -- 하이라이트 유지
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local hlgrp = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = hlgrp,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = hlgrp,
              callback = vim.lsp.buf.clear_references,
            })
            -- 오타 수정: nvim_create_autocmd
            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(ev2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = ev2.buf })
              end,
            })
          end

          -- Inlay Hints 토글 (0.9/0.10 호환)
          local ih = vim.lsp.inlay_hint or (vim.lsp.buf and vim.lsp.buf.inlay_hint)
          if ih and client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
              if type(ih) == "table" and ih.is_enabled and ih.enable then
                local enabled = ih.is_enabled(event.buf)
                ih.enable(not enabled, { bufnr = event.buf })
              else
                -- 0.9 스타일: function(enable, {bufnr=?})
                local cur = vim.b.inlay_hint_enabled or false
                ih(not cur, { bufnr = event.buf })
                vim.b.inlay_hint_enabled = not cur
              end
            end, "[T]oggle Inlay [H]ints")
          end

          -- 워크스페이스 폴더 유틸
          map("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
          map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
          map("<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, "[W]orkspace [L]ist Folders")
        end,
      })

      -- cmp capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- 서버 설정
      local servers = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              runtime = { version = "LuaJIT" },
              workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
              diagnostics = { globals = { "vim" }, disable = { "missing-fields" } },
              format = { enable = false },
            },
          },
        },
        pyright = { enabled = false },
        ruff = { enabled = false },
        pylsp = {
          settings = {

            pylsp = {
              plugins = {
                rope_autoimport = {
                  enabled = true,
                },
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                mccabe = { enabled = false },
                pylsp_mypy = { enabled = false },
                pylsp_black = { enabled = false },
                pylsp_isort = { enabled = false },
              },
            },
          },
        },
        -- ruff = { enabled = true },
        -- ts_ls
        ts_ls = {
          init_options = {
            plugins = {
              {
                name = "@vue/typescript-plugin",
                location = vim.fn.stdpath("data")
                  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                languages = { "vue" },
              },
            },
          },
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        },
        volar = {},
        jsonls = {},
        sqlls = {},
        terraformls = {},
        yamlls = {},
        bashls = {},
        dockerls = {},
        docker_compose_language_service = {},
        html = { filetypes = { "html", "twig", "hbs" } },
      }

      -- Mason ensure (패키지 이름 매핑)
      local mason_map = {
        volar = "vue-language-server",
        ts_ls = "typescript-language-server",
      }
      local ensure = {}
      for name, _ in pairs(servers) do
        table.insert(ensure, mason_map[name] or name)
      end
      vim.list_extend(ensure, { "stylua" })
      require("mason-tool-installer").setup({ ensure_installed = ensure })

      -- 서버 적용 (네이티브 API 있으면 사용, 없으면 lspconfig로)
      local has_native = (vim.lsp and vim.lsp.config and vim.lsp.enable)
      local lspconfig = not has_native and require("lspconfig") or nil

      for name, cfg in pairs(servers) do
        cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})
        if has_native then
          vim.lsp.config(name, cfg)
          vim.lsp.enable(name)
        else
          lspconfig[name].setup(cfg)
        end
      end
    end,
  },
}
