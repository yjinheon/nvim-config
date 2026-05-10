return {
  -- {
  --   "<leader>.",
  --   function()
  --     Snacks.scratch()
  --   end,
  --   desc = "Toggle Scratch Buffer",
  -- },
  {
    "<leader>ts",
    function()
      -- Vault 경로 (원하는 경로로 변경)
      local vault = "~/workspace/astro-blog/01.Project"
      vault = vim.fn.expand(vault)

      -- Vault 아래 todo 파일들 찾기 (재귀적으로)
      local files = vim.fn.globpath(vault, "**/**_todo.md", false, true)

      if #files == 0 then
        vim.notify("No files found in " .. vault, vim.log.levels.WARN)
        return
      end

      -- 파일 목록 선택 UI
      vim.ui.select(files, {
        prompt = "Select a scratch file:",
        format_item = function(item)
          return vim.fn.fnamemodify(item, ":~:.") -- 경로 짧게 표시
        end,
      }, function(choice)
        if choice then
          Snacks.scratch.open({
            ft = "markdown",
            file = choice,
          })
        end
      end)
    end,
    desc = "Select Scratch Buffer (Vault Files)",
  },
  {
    "<leader>tt",
    function()
      -- 원하는 Vault 경로 지정
      local vault = "~/workspace/astro-blog/01.Project"
      vault = vim.fn.expand(vault) -- ~ 확장

      -- 현재 git root (없으면 cwd)
      local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
      if vim.v.shell_error ~= 0 or git_root == nil or git_root == "" then
        git_root = vim.fn.getcwd()
      end

      -- 프로젝트 이름 추출 (폴더명만)
      local project_name = vim.fn.fnamemodify(git_root, ":t")

      -- Vault 안에 프로젝트별 디렉토리 생성
      local project_dir = vault .. "/" .. project_name

      vim.fn.mkdir(project_dir, "p")

      -- todo 파일 경로
      -- local file = project_dir .. "/todo.md"
      local file = string.format("%s/%s_todo.md", project_dir, project_name)

      if vim.fn.filereadable(file) == 0 then
        local template = vim.fn.expand("~/workspace/astro-blog/02.Area/template/project-template.md")
        if vim.fn.filereadable(template) == 0 then
          vim.notify("Todo template not found: " .. template, vim.log.levels.ERROR)
          return
        end

        local lines = vim.fn.readfile(template)
        local ok = vim.fn.writefile(lines, file)
        if ok ~= 0 then
          vim.notify("Failed to create todo file: " .. file, vim.log.levels.ERROR)
          return
        end
      end

      -- Scratch buffer 열기
      Snacks.scratch.open({
        ft = "markdown",
        file = file,
      })
    end,
    desc = "Toggle Project Todo (Vault)",
  },
}
