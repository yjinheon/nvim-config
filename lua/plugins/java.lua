return {
  {
    "nvim-java/nvim-java",
    config = false,
    dependencies = {
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
                  -- version = 'v1.43.0',
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
                  -- version = '0.58.1',
                },
                spring_boot_tools = {
                  enable = true,
                  version = "1.63.0",
                },
              })
            end,
          },
        },
      },
    },
  },
}
