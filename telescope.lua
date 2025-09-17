return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {

      defaults = {
        vimgrep_arguments = {
          "--color=always",
          "--line-number",
          "--no-heading",
          -- "--smart-case '${*:-}'",
          "--smart-case",
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

      keys = {
        -- find_files 오버라이드 - 파일 생성 기능 포함
        {
          "<leader>ff",
          function()
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            -- 파일 생성 함수
            local function create_file(prompt_bufnr)
              local picker = action_state.get_current_picker(prompt_bufnr)
              actions.close(prompt_bufnr)

              vim.ui.input({ prompt = "New file: " }, function(input)
                if input and input ~= "" then
                  -- 더 안전한 경로 처리
                  local base_dir = picker.cwd or vim.fn.getcwd()
                  local filepath = vim.fs.joinpath(base_dir, input)

                  -- 디렉토리가 없으면 생성
                  local dir = vim.fn.fnamemodify(filepath, ":h")
                  if vim.fn.isdirectory(dir) == 0 then
                    vim.fn.mkdir(dir, "p")
                  end

                  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
                end
              end)
            end

            require("telescope.builtin").find_files({
              -- find_files에서만 적용되는 매핑
              attach_mappings = function(prompt_bufnr, map)
                -- 기본 동작 유지
                actions.select_default:replace(actions.select_default)

                -- 파일 생성 매핑 추가 (normal mode)
                map("n", "<C-f>", create_file)

                -- 파일 생성 매핑 추가 (insert mode)
                map("i", "<C-f>", create_file)

                return true -- 기본 매핑 유지
              end,
            })
          end,
          desc = "Find files (with create)",
        },
      },
    },
  },
  --lazy
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        extensions = {
          file_browser = {
            theme = "ivy",
            hijack_netrw = true, -- netrw 비활성화하고 file_browser 사용
            mappings = {
              ["i"] = {
                ["<C-n>"] = require("telescope._extensions.file_browser.actions").create,
                ["<C-r>"] = require("telescope._extensions.file_browser.actions").rename,
                ["<C-d>"] = require("telescope._extensions.file_browser.actions").remove,
              },
              ["n"] = {
                ["c"] = require("telescope._extensions.file_browser.actions").create,
                ["r"] = require("telescope._extensions.file_browser.actions").rename,
                ["d"] = require("telescope._extensions.file_browser.actions").remove,
              },
            },
          },
        },
      })
      require("telescope").load_extension("file_browser")
    end,
    keys = {
      {
        "<leader>fd",
        ":Telescope file_browser<CR>",
        desc = "File Browser",
      },
      {
        "<leader>fD",
        ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
        desc = "File Browser (current file directory)",
      },
    },
  },
}
