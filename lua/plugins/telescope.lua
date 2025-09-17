return {
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      -- 기존 설정 초기화
      opts.defaults = opts.defaults or {}
      opts.extensions = opts.extensions or {}

      -- vimgrep_arguments 설정
      opts.defaults.vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      }

      -- fzf 확장 설정
      opts.extensions.fzf = vim.tbl_deep_extend("force", opts.extensions.fzf or {}, {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      })

      return opts
    end,
  },
  {
    "nvim-telescope/telescope-dap.nvim",
  },
}
