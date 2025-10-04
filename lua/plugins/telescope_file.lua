return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local themes = require("telescope.themes")

    local fb_theme = themes.get_dropdown({
      prompt_title = "📁 File Browser",
      previewer = false,
      winblend = 10, -- 투명도
      layout_config = {
        width = 0.6,
        height = 0.5,
      },
    })

    telescope.setup({
      extensions = {
        file_browser = vim.tbl_extend("force", fb_theme, {
          hijack_netrw = true, -- netrw 비활성화하고 file_browser 사용
        }),
      },
    })

    telescope.load_extension("file_browser")
  end,
  keys = {
    {
      "<leader>fW",
      ":Telescope file_browser<CR>",
      desc = "File Browser",
    },
    {
      "<leader>fw",
      ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
      desc = "File Browser (current file directory)",
    },
  },
}
