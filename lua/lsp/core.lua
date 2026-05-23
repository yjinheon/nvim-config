local M = {}

local function map_lsp(event, keys, rhs, desc)
  vim.keymap.set("n", keys, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
end

function M.setup_attach()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
    callback = function(event)
      pcall(vim.keymap.del, "n", "K", { buffer = event.buf })
      pcall(vim.keymap.del, "n", "K")

      local ok_tb, tb = pcall(require, "telescope.builtin")

      map_lsp(event, "gd", "<cmd>Lspsaga goto_definition<CR>", "[G]oto [D]efinition")
      map_lsp(event, "gp", "<cmd>Lspsaga peek_definition<CR>", "Pe[e]k Definition")
      map_lsp(event, "gr", "<cmd>Lspsaga finder<CR>", "[G]oto [R]eferences (Finder)")
      map_lsp(event, "gI", "<cmd>Lspsaga finder<CR>", "[G]oto [I]mplementations (Finder)")
      map_lsp(event, "<leader>D", "<cmd>Lspsaga goto_type_definition<CR>", "Type [D]efinition")
      map_lsp(event, "<leader>ds", "<cmd>Lspsaga outline<CR>", "[D]ocument [S]ymbols (Outline)")

      if ok_tb then
        map_lsp(event, "<leader>ws", tb.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
      else
        map_lsp(event, "<leader>ws", "<cmd>Lspsaga outline<CR>", "[W]orkspace [S]ymbols (Outline)")
      end

      map_lsp(event, "<leader>rn", "<cmd>Lspsaga rename<CR>", "[R]e[n]ame")
      map_lsp(event, "K", "<cmd>Lspsaga hover_doc<CR>", "Hover Documentation")
      map_lsp(event, "gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
      map_lsp(event, "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", "Next Diagnostic")
      map_lsp(event, "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Prev Diagnostic")
      map_lsp(event, "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", "Cursor Diagnostics")

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
        vim.api.nvim_create_autocmd("LspDetach", {
          group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
          callback = function(ev2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = ev2.buf })
          end,
        })
      end

      local ih = vim.lsp.inlay_hint or (vim.lsp.buf and vim.lsp.buf.inlay_hint)
      if ih and client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        map_lsp(event, "<leader>th", function()
          if type(ih) == "table" and ih.is_enabled and ih.enable then
            local enabled = ih.is_enabled(event.buf)
            ih.enable(not enabled, { bufnr = event.buf })
          else
            local cur = vim.b.inlay_hint_enabled or false
            ih(not cur, { bufnr = event.buf })
            vim.b.inlay_hint_enabled = not cur
          end
        end, "[T]oggle Inlay [H]ints")
      end

      map_lsp(event, "<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
      map_lsp(event, "<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
      map_lsp(event, "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, "[W]orkspace [L]ist Folders")
    end,
  })
end

function M.default_servers()
  return vim.tbl_deep_extend("force", require("lang.go").lsp_servers(), {
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
    clangd = {},
    html = { filetypes = { "html", "twig", "hbs" } },
  })
end

function M.mason_package_names(servers)
  local mason_map = {
    bashls = "bash-language-server",
    docker_compose_language_service = "docker-compose-language-service",
    dockerls = "dockerfile-language-server",
    html = "html-lsp",
    jsonls = "json-lsp",
    lua_ls = "lua-language-server",
    pylsp = "python-lsp-server",
    terraformls = "terraform-ls",
    ts_ls = "typescript-language-server",
    volar = "vue-language-server",
    yamlls = "yaml-language-server",
  }

  local ensure = {}
  for name, _ in pairs(servers) do
    table.insert(ensure, mason_map[name] or name)
  end
  vim.list_extend(ensure, { "stylua" })

  return ensure
end

function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  return vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
end

function M.setup_servers(servers)
  require("mason-tool-installer").setup({ ensure_installed = M.mason_package_names(servers) })

  local capabilities = M.capabilities()
  local has_native = vim.lsp and vim.lsp.config and vim.lsp.enable
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
end

function M.setup()
  M.setup_attach()
  M.setup_servers(M.default_servers())
end

return M
