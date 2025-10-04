return {
  {
    "nvim-java/nvim-java",
    priority = 1000,
    config = false,
    dependencies = {
      "nvim-java/lua-async-await",
      "nvim-java/nvim-java-core",
      "nvim-java/nvim-java-test",
      "MunifTanjim/nui.nvim",
      {
        "neovim/nvim-lspconfig",
        opts = {
          servers = {
            jdtls = {
              -- Your custom jdtls settings goes here
            },
          },
          setup = {
            jdtls = function()
              require("java").setup({

                jdk = {
                  auto_install = false,
                },
                -- custom nvim-java configuration
                root_markers = {
                  "settings.gradle",
                  "settings.gradle.kts",
                  "pom.xml",
                  "build.gradle",
                  "mvnw",
                  "gradlew",
                  "build.gradle",
                  "build.gradle.kts",
                  ".git",
                },
                jdtls = {
                  version = "v1.43.0",
                  language_servers = {
                    {
                      name = "spring-boot-language-server",
                      command = { "spring-boot-language-server", "--stdio" },
                      root_patterns = { "pom.xml", "build.gradle" },
                      filetypes = { "java" },
                    },
                  },
                },
                lombok = {
                  -- version = 'nightly',
                },
                java_test = {
                  enable = true,
                  version = "0.43.0",
                },
                java_debug_adapter = {
                  enable = true,
                  -- version = '1.58.1',
                },
                spring_boot_tools = {
                  enable = false,
                  version = "1.63.0",
                },
              })
              --require("lspconfig").jdtls.setup({})
            end,
          },
        },
      },
    },
  },
}
