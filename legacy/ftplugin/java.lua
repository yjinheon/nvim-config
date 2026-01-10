local ok, jdtls = pcall(require, "jdtls")
if not ok then
  return
end

local root =
  require("jdtls.setup").find_root({ "gradlew", "mvnw", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
if not root or root == "" then
  return
end

for _, c in ipairs(vim.lsp.get_active_clients({ name = "jdtls" })) do
  if c.config and c.config.root_dir == root then
    return
  end
end

local mason = vim.fn.stdpath("data") .. "/mason/packages/"
local bundles = {}
local debug = vim.fn.glob(mason .. "java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1)
if debug ~= "" then
  table.insert(bundles, debug)
end
for _, j in ipairs(vim.split(vim.fn.glob(mason .. "java-test/extension/server/*.jar", 1), "\n")) do
  if j ~= "" then
    table.insert(bundles, j)
  end
end

if #bundles == 0 then
  vim.notify("[jdtls] java-debug/test bundles not found (Mason 설치 확인)", vim.log.levels.ERROR)
  return
end

local ws = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":p:h:t")

require("jdtls").start_or_attach({
  cmd = { "jdtls" },
  root_dir = root,
  workspace_folders = { { name = vim.fn.fnamemodify(root, ":t"), uri = "file://" .. root } },
  init_options = { bundles = bundles }, -- ★ 이게 핵심
  settings = { java = { signatureHelp = { enabled = true }, contentProvider = { preferred = "fernflower" } } },
})

-- DAP(main-class 자동 스캔)
require("jdtls").setup_dap({ hotcodereplace = "auto" })
pcall(function()
  require("jdtls").setup_dap_main_class_configs()
end)
