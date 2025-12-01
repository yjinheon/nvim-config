return {
  -- add onenord
  { "rmehri01/onenord.nvim" },
  -- {
  --   "philosofonusus/morta.nvim",
  --   name = "morta",
  --   priority = 1000,
  --   opts = {},
  --   config = function()
  --     vim.cmd.colorscheme("morta")
  --   end,
  -- },
  -- { "notken12/base46-colors" },
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1001,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  -- {
  --   "catppuccin",
  --   priority = 1000,
  --   opts = {
  --     flavour = "macchiato", --latte, frappe, macchiato,mocha
  --     styles = {
  --       comments = { "italic", "underline" },
  --       conditionals = { "italic" },
  --       loops = {},
  --       functions = {},
  --       keywords = {},
  --       strings = {},
  --       variables = {},
  --       numbers = {},
  --       booleans = {},
  --       properties = {},
  --       types = {},
  --       operators = {},
  --       -- miscs = {}, -- Uncomment to turn off hard-coded styles
  --     },
  --   },
  -- },
  { "diegoulloao/neofusion.nvim", priority = 1000, config = true, opts = ... },
  {
    "xiyaowong/transparent.nvim",
    opts = {
      extra_groups = {
        "NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
        "NvimTreeNormal",
        "NeoTreeCursorLine",
        "NeoTreeDimText",
        "NeoTreeDirectoryIcon",
        "NeoTreeDirectoryName",
        "NeoTreeDotfile",
        "NeoTreeFileIcon",
        "NeoTreeFileName",
        "NeoTreeFileNameOpene",
        "NeoTreeFilterTerm",
        "NeoTreeFloatBorder",
        "NeoTreeFloatTitle",
        "NeoTreeTitleBar",
        "NeoTreeGitAdded",
        "NeoTreeGitConflict",
        "NeoTreeGitDeleted",
        "NeoTreeGitIgnored",
        "NeoTreeGitModified",
        "NeoTreeGitUnstaged",
        "NeoTreeGitUntracke",
        "NeoTreeGitStaged",
        "NeoTreeHiddenByName",
        "NeoTreeIndentMarker",
        "NeoTreeExpander",
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeSignColumn",
        "NeoTreeStatusLine",
        "NeoTreeStatusLineNC",
        "NeoTreeVertSplit",
        "NeoTreeWinSeparator",
        "NeoTreeEndOfBuffer",
        "NeoTreeRootName",
        "NeoTreeSymbolicLinkTarget",
        "NeoTreeTitleBar",
        "NeoTreeWindowsHidden",
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = false,
      --   styles = {
      --     sidebars = "transparent",
      --     flaoats = "transparent",
      --   },
    },
  },
  { "Mofiqul/dracula.nvim" },
  --nord
  { "shaunsingh/nord.nvim" },
  -- { "Shatur/neovim-ayu" },
  --kanagawa
  -- { "rebelot/kanagawa.nvim" },
  --everforest
  -- { "sainnhe/everforest" },
  --monokai
  { "polirritmico/monokai-nightasty.nvim" },
  -- nightfox
  { "EdenEast/nightfox.nvim" },
  -- Configure LazyVim to load gruvbox
  {
    "nyoom-engineering/oxocarbon.nvim",
    -- Add in any other configuration;
    --   event = foo,
    --   config = bar
    --   end,
  },
  -- {
  --   "craftzdog/solarized-osaka.nvim",
  -- },
  -- {
  --   "nvchad/base46",
  --   lazy = true,
  --   build = function()
  --     require("base46").load_all_highlights()
  --   end,
  -- },
  {
    "LazyVim/LazyVim",
    opts = {
      --      colorscheme = "solarized-osaka",
      --      colorscheme = "doomchad",
      --colorscheme = "nightfox",
      --      colorscheme = "tokyonight-moon",
      --colorscheme = "tokyonight-storm",
      --      colorscheme = "morta",
      --colorscheme = "tokyonight-day",
      --colorscheme = "tokyonight-night",
      --     colorscheme = "kanagawa",
      --colorscheme = "catppuccin-frappe",
      --colorscheme = "monekai",
      -- colorscheme = "monokai-nightasty", -- or "gruvbox" --catppuccin fr:w
      colorscheme = "catppuccin",
      --colorscheme = "neofusion",
      --colorscheme = "dracula",
      -- colorscheme = "monokai-nightasty",
      --colorscheme = "neovim-ayu",
      --      colorscheme = "gruvbox",
      --colorscheme = "neofusion",
      --colorscheme = "catppuccin",
    },
  },
}
