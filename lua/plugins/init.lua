--require("config.lazy")
--require("luasnip/loaders/from_vscode").lazy_load()

--local snip_loader = require("luasnip/loaders/from_vscode")
--snip_loader.lazy_load()
--snip_loader.load({ paths = { "~/.config/nvim/snippets" } })

-- set clipboard=unnamedplus

return {
  -- {
  --   "stevearc/conform.nvim",
  --   event = "BufWritePre", -- uncomment for format on save
  --   config = function()
  --     require("config.conform")
  --   end,
  -- },
  -- {
  --   "jackMort/ChatGPT.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     require("chatgpt").setup({
  --       -- read from .env file
  --       api_key = os.getenv("GPT_API_KEY"),
  --       api_key_cmd = "echo " .. os.getenv("GPT_API_KEY"),
  --     })
  --   end,
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "folke/trouble.nvim",
  --     "nvim-telescope/telescope.nvim",
  --   },
  -- },
  -- -- venv selector
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
    opts = {
      -- Your options go here
      name = { "venv", ".venv" },
      -- auto_refresh = false
    },
    event = "VeryLazy", -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
    keys = {
      -- Keymap to open VenvSelector to pick a venv.
      { "<leader>vs", "<cmd>VenvSelect<cr>" },
      -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
      { "<leader>vc", "<cmd>VenvSelectCached<cr>" },
    },
  },
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    event = "LspAttach",
    config = function()
      require("tiny-code-action").setup()
    end,
  },
  {
    "keaising/im-select.nvim", -- switch input method automatically
    config = function()
      require("im_select").setup({})
    end,
  },
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Comment toggle current line" },
      { "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
      { "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
      { "gbc", mode = "n", desc = "Comment toggle current block" },
      { "gb", mode = { "n", "o" }, desc = "Comment toggle blockwise" },
      { "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
    },
    config = function(_, opts)
      require("Comment").setup(opts)
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    lazy = false,
    enabled = true,
  },
  {
    "voldikss/vim-floaterm",
    lazy = false,
    enabled = true,
  },
  {
    "liuchengxu/vista.vim",
    lazy = false,
    enabled = true,
  },
  {
    "L3MON4D3/LuaSnip",
    lazy = false,
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
  },
  -- noice.nvim
  -- {
  --   "s1n7ax/nvim-noice",
  --   lazy = false,
  --   enabled = true,
  -- },
  {
    "folke/twilight.nvim",
    opts = {
      twilight = {
        dimming = {
          alpha = 0.25, -- amount of dimming
          -- we try to get the foreground from the highlight groups or fallback color
          color = { "Normal", "#ffffff" },
        },
        context = 10, -- amount of lines we will try to show around the current line
        treesitter = true, -- use treesitter when available for the filetype
        -- treesitter is used to automatically expand the visible text,
        -- but you can further control the types of nodes that should always be fully expanded
        expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
          "function",
          "method",
          "table",
          "if_statement",
        },
        exclude = {}, -- exclude these filetypes
      },
    },
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
        width = 120, -- width of the Zen window
        height = 1, -- height of the Zen window
        options = {
          signcolumn = "no", -- disable signcolumn
          number = false, -- disable number column
          relativenumber = false, -- disable relative numbers
          cursorline = false, -- disable cursorline
          cursorcolumn = false, -- disable cursor column
          foldcolumn = "0", -- disable fold column
          list = false, -- disable whitespace characters
        },
      },
      plugins = {
        gitsigns = { enabled = false }, -- disables git signs
        tmux = { enabled = false }, -- disables the tmux statusline
        twilight = { enabled = false }, -- disables twilight
      },
      on_open = function()
        vim.cmd([[
        set foldlevel=20
      ]])
      end,
      on_close = function()
        vim.cmd([[
        set foldlevel=0
      ]])
      end,
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {

      defaults = {
        vimgrep_arguements = {
          "--color=always",
          "--line-number",
          "--no-heading",
          "--smart-case '${*:-}'",
        },
      },

      extensions = {
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        },
      },
    },
  },
  {
    "garymjr/nvim-snippets",
    opts = {
      friendly_snippets = false,
    },
    dependencies = { "rafamadriz/friendly-snippets" },
  },
  -- {
  --   "VonHeikemen/fine-cmdline.nvim",
  --   lazy = false,
  --   enabled = true,
  -- },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      source_selector = {
        winbar = true,
      },
      filtered_items = {
        hide_hidden = false,
      },
    },
  },
  {
    -- Add indentation guides even on blank lines
    "lukas-reineke/indent-blankline.nvim",
    version = "3.5.4",
    main = "ibl",
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "ahmedkhalf/project.nvim",
    opts = {
      manual_mode = false,
    },
  },
  -- lazy.nvim:

  --
  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
