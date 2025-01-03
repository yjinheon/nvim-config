return {
  -- add onenord
  { "rmehri01/onenord.nvim" },
  { "notken12/base46-colors" },
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  -- add catppuccin
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   opts = {
  --     flavour = "mocha", --latte, frappe, macchiato,mocha
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
  { "Shatur/neovim-ayu" },
  --kanagawa
  { "rebelot/kanagawa.nvim" },
  --everforest
  { "sainnhe/everforest" },
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
  {
    "craftzdog/solarized-osaka.nvim",
  },
  {
    "nvchad/base46",
    lazy = true,
    build = function()
      require("base46").load_all_highlights()
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      --     colorscheme = "doomchad",
      --colorscheme = "nightfox",
      --      colorscheme = "tokyonight-moon",
      colorscheme = "tokyonight-storm",
      --colorscheme = "tokyonight-day",
      --colorscheme = "tokyonight-night",
      --     colorscheme = "kanagawa",
      --colorscheme = "catppuccin",
      --colorscheme = "monekai",
      -- colorscheme = "monokai-nightasty", -- or "gruvbox" --catppuccin fr:w
      --colorscheme = "neofusion",
      --colorscheme = "nightfox",
      -- colorscheme = "dracula"
      -- colorscheme = "monokai-nightasty",
      --colorscheme = "neovim-ayu",
      --      colorscheme = "gruvbox",
      --colorscheme = "neofusion",
    },
  },
}
