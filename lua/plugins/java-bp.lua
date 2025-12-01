-- ~/.config/nvim/lua/plugins/java-bulletproof.lua
return {
  -- nvim-java: 번들 주입/명령 제공(실행/디버그)
  {
    "nvim-java/nvim-java",
    ft = "java",
    priority = 1001,
    dependencies = {
      "nvim-java/lua-async-await",
      "nvim-java/nvim-java-core",
      "nvim-java/nvim-java-test",
      "MunifTanjim/nui.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("java").setup({
        jdk = { auto_install = false },
        root_markers = {
          "settings.gradle",
          "settings.gradle.kts",
          "pom.xml",
          "build.gradle",
          "build.gradle.kts",
          "mvnw",
          "gradlew",
          ".git",
        },
        java_test = { enable = true, version = "0.43.1" },
        java_debug_adapter = { enable = true, version = "0.58.2" },
        lombok = {},
        spring_boot_tools = {
          enable = false,
          version = "1.63.0",
        },

        -- Spring Boot LSP
        jdtls = {
          language_servers = {
            {
              name = "spring-boot-language-server",
              command = { "spring-boot-language-server", "--stdio" },
              root_patterns = { "pom.xml", "build.gradle", "build.gradle.kts" },
              filetypes = { "java" },
            },
          },
        },
      })
    end,
  },

  -- lspconfig가 jdtls를 건드리지 못하게 완전 차단
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.setup = opts.setup or {}
      opts.servers.jdtls = nil
      opts.setup.jdtls = function()
        return true
      end
      return opts
    end,
  },

  -- mason-lspconfig가 jdtls를 ensure_installed에 넣지 못하게
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      if opts.ensure_installed then
        local keep = {}
        for _, name in ipairs(opts.ensure_installed) do
          if name ~= "jdtls" then
            table.insert(keep, name)
          end
        end
        opts.ensure_installed = keep
      end
      return opts
    end,
  },

  -- jdtls 선 attach 오토커맨드 (bundles 강제 주입)
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local mason = vim.fn.stdpath("data") .. "/mason/packages/"
      local function collect_bundles()
        local bundles = {}
        local debug =
          vim.fn.glob(mason .. "java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1)
        if debug ~= "" then
          table.insert(bundles, debug)
        end
        local tests = vim.split(vim.fn.glob(mason .. "java-test/extension/server/*.jar", 1), "\n")
        for _, j in ipairs(tests) do
          if j ~= "" then
            table.insert(bundles, j)
          end
        end
        return bundles
      end

      local function start_jdtls_if_needed()
        -- 파일타입이 진짜 java인지 보장
        if vim.bo.filetype ~= "java" then
          return
        end

        local root = require("jdtls.setup").find_root({
          "gradlew",
          "mvnw",
          "pom.xml",
          "build.gradle",
          "build.gradle.kts",
          ".git",
        })
        if not root or root == "" then
          -- 루트가 없으면 jdtls attach 안 함 (싱글파일 모드 회피)
          return
        end

        -- 이미 같은 root로 붙어 있으면 패스
        for _, client in ipairs(vim.lsp.get_active_clients({ name = "jdtls" })) do
          if client.config and client.config.root_dir == root then
            return
          end
        end

        local ws = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":p:h:t")
        local bundles = collect_bundles()

        local config = {
          cmd = { "jdtls" },
          root_dir = root,
          workspace_folders = { { name = vim.fn.fnamemodify(root, ":t"), uri = "file://" .. root } },
          init_options = { bundles = bundles }, -- ★ 핵심
          settings = {
            java = {
              signatureHelp = { enabled = true },
              contentProvider = { preferred = "fernflower" },
            },
          },
          -- 필요하면 여기에 on_attach 키맵 추가 가능
        }

        require("jdtls").start_or_attach(config)
      end

      -- Java 버퍼가 열릴 때마다 jdtls 먼저!
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.java" },
        callback = function()
          start_jdtls_if_needed()
        end,
      })
    end,
  },
}
