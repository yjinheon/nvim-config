-- ============================================================================
-- 통합 DAP 설정 (Python / Go / Java 전용) - dap.lua 스타일 정리 버전
--  - nvim-dap + dap-ui + virtual-text + REPL 하이라이트
--  - Python(debugpy), Go(delve), Java(jdtls 연동)만 활성화
--  - 키맵은 기존 dap2.lua의 기능에 맞춤(종료/위젯/UI 토글/Eval/파이썬 테스트)
-- ============================================================================

return {
  {
    -- 핵심 DAP 플러그인
    "mfussenegger/nvim-dap",
    lazy = true,

    -- ------------------------------
    -- 키맵 (dap2.lua 기능 중심)
    -- ------------------------------
    --  - <leader>dt : 디버그 세션 종료
    --  - <leader>dK : DAP 위젯(hover) 열기
    --  - <leader>du : DAP UI 토글
    --  - <leader>dE : 커서 변수/표현식 평가(Eval, 노멀/비주얼)
    --  - 파이썬만: <F10> 메서드 테스트, <leader>dpc 클래스 테스트, <leader>dps 선택영역 디버그
    keys = {
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "디버그 종료",
      }, -- :contentReference[oaicite:4]{index=4}
      {
        "<leader>dK",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "DAP 위젯(Hover)",
      }, -- :contentReference[oaicite:5]{index=5}
      {
        "<leader>du",
        function()
          require("dapui").toggle({})
        end,
        desc = "DAP UI 토글",
      }, -- :contentReference[oaicite:6]{index=6}
      {
        "<leader>dE",
        function()
          require("dapui").eval()
        end,
        desc = "Eval",
        mode = { "n", "v" },
      }, -- :contentReference[oaicite:7]{index=7}

      -- Python 전용 단축키 (debugpy)
      {
        "<F10>",
        function()
          require("dap-python").test_method()
        end,
        desc = "Python: 메서드 테스트",
        ft = "python",
      }, -- :contentReference[oaicite:8]{index=8}
      {
        "<leader>dpc",
        function()
          require("dap-python").test_class()
        end,
        desc = "Python: 클래스 테스트",
        ft = "python",
      }, -- :contentReference[oaicite:9]{index=9}
      {
        "<leader>dps",
        function()
          require("dap-python").debug_selection()
        end,
        desc = "Python: 선택영역 디버그",
        ft = "python",
      }, -- :contentReference[oaicite:10]{index=10}
    },

    -- ------------------------------
    -- 의존 플러그인
    -- ------------------------------
    dependencies = {
      -- DAP UI: 변수/스코프/브레이크포인트/REPL 패널
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
      },

      -- 소스 코드 옆에 변수값을 가상 텍스트로 표시
      { "theHamsta/nvim-dap-virtual-text" },

      -- DAP REPL 문법 하이라이트(Treesitter 파서 자동 설치)
      {
        "LiadOz/nvim-dap-repl-highlights",
        config = true,
        dependencies = {
          "mfussenegger/nvim-dap",
          "nvim-treesitter/nvim-treesitter",
        },
        build = function()
          if not require("nvim-treesitter.parsers").has_parser("dap_repl") then
            vim.cmd(":TSInstall dap_repl")
          end
        end,
      },

      -- Python 디버깅(debugpy)
      {
        "mfussenegger/nvim-dap-python",
        keys = config.dap_python.keys,
        config = function()
          -- mason에 설치된 debugpy의 venv 파이썬을 사용 (원래 동작)
          local path = require("mason-registry").get_package("debugpy"):get_install_path()
          require("dap-python").setup(path .. "/venv/bin/python")
        end,
      },

      -- Go 디버깅(delve)
      { "leoluz/nvim-dap-go", config = true }, -- 플러그인 기본 설정 사용

      -- Java DAP 활성화를 위한 jdtls 연동(언어 서버는 프로젝트별로 기동)
      --{ "mfussenegger/nvim-jdtls" },
    },

    -- ------------------------------
    -- 설정 본문
    -- ------------------------------
    config = function()
      local ok_dap, dap = pcall(require, "dap")
      if not ok_dap then
        return
      end

      -- ============================================================
      -- DAP 사인(아이콘) 정의: 중단점/거부/정지 표시
      --  - 네오빔 사이드 라인(사인 열)에 이모지 기반으로 표시
      -- ============================================================
      local signs = {
        error = { text = "🟥", texthl = "DiagnosticsSignError", linehl = "", numhl = "" },
        rejected = { text = "", texthl = "DiagnosticsSignHint", linehl = "", numhl = "" },
        stopped = {
          text = "⭐️",
          texthl = "DiagnosticsSignInfo",
          linehl = "DiagnosticUnderlineInfo",
          numhl = "DiagnosticsSignInfo",
        },
      }
      vim.fn.sign_define("DapBreakpoint", signs.error) -- 일반 중단점    :contentReference[oaicite:11]{index=11}
      vim.fn.sign_define("DapStopped", signs.stopped) -- 현재 정지 위치  :contentReference[oaicite:12]{index=12}
      vim.fn.sign_define("DapBreakpointRejected", signs.rejected) -- 중단점 거부  :contentReference[oaicite:13]{index=13}

      -- ============================================================
      -- DAP UI: 창 배치/아이콘/플로팅/오픈·클로즈 자동화
      --  - 디버그 시작 시 자동 오픈, 종료·종료 이벤트에서 자동 닫기
      -- ============================================================
      local dapui = require("dapui")
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸" }, -- 트리 확장/축소 아이콘              :contentReference[oaicite:14]{index=14}
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        }, -- UI 조작 키
        layouts = {
          {
            elements = { { id = "scopes", size = 0.25 }, "breakpoints", "watches" }, -- 좌측 패널 구성   :contentReference[oaicite:15]{index=15}
            size = 40,
            position = "left",
          },
          {
            elements = { "repl", "console" }, -- 하단 패널(REPL/콘솔)                    :contentReference[oaicite:16]{index=16}
            size = 0.25,
            position = "bottom",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "rounded",
          mappings = { close = { "q", "<Esc>" } }, -- 플로팅 창 닫기 키
        },
        windows = { indent = 1 },
        render = { max_type_length = nil },
      })

      -- 디버그 수명 주기 이벤트에 맞춰 UI 자동 열기/닫기
      dap.listeners.after.event_initialized["dapui_auto_open"] = function()
        dapui.open({})
      end -- 시작 시 열기  :contentReference[oaicite:17]{index=17}
      dap.listeners.before.event_terminated["dapui_auto_close"] = function()
        dapui.close({})
      end -- 종료 시 닫기  :contentReference[oaicite:18]{index=18}
      dap.listeners.before.event_exited["dapui_auto_close"] = function()
        dapui.close({})
      end -- 프로세스 종료 시 닫기

      -- ============================================================
      -- 가상 텍스트: 소스 옆에 변수값/변경 이유 표시
      --  - commented = true: 주석 프리픽스 붙여 가독성↑
      -- ============================================================
      require("nvim-dap-virtual-text").setup({
        enabled = true, -- 플러그인 활성화
        enabled_commands = true, -- :DapVirtualText* 명령 노출
        highlight_changed_variables = true, -- 변경된 변수 강조
        highlight_new_as_changed = false, -- 신규 변수를 변경과 동일하게 표시 여부
        show_stop_reason = true, -- 예외로 멈췄을 때 이유 표시
        commented = true, -- 주석 접두어 사용(원본과 동일)            :contentReference[oaicite:19]{index=19}
        only_first_definition = true, -- 첫 정의 지점에만 표시
        all_references = false, -- 모든 참조에 표시하지 않음
        filter_references_pattern = "<module", -- Python 모듈 참조는 필터링
        virt_text_pos = "eol", -- 라인 끝(eol)에 표시
        all_frames = false, -- 현재 스택 프레임만
        virt_lines = false,
        virt_text_win_col = nil,
      })

      -- 로그 레벨(필요 시 "TRACE"로 변경하여 트러블슈팅 강화)
      dap.set_log_level("INFO")

      -- ============================================================
      -- Python(debugpy)
      --  - 우선 'uv' 런처 사용, 없으면 mason debugpy venv 파이썬 사용
      --  - F10/클래스/선택 영역 테스트 키는 상단 keys에서 정의
      -- ============================================================
      -- dap-python setup만 교체
      -- local ok_py, dap_python = pcall(require, "dap-python")
      -- if ok_py then
      --   local python = "python" -- 최후의 최후 폴백
      --   -- mason debugpy venv가 있으면 최우선 사용
      --   pcall(function()
      --     local registry = require("mason-registry")
      --     if registry.has_package("debugpy") then
      --       local p = registry.get_package("debugpy"):get_install_path()
      --       local venv_python = p .. "/venv/bin/python"
      --       if vim.fn.executable(venv_python) == 1 then
      --         python = venv_python
      --       end
      --     end
      --   end)
      --   -- uv가 존재하면 uv 사용(원할 때만)
      --   if vim.fn.executable("uv") == 1 then
      --     python = "uv"
      --   end
      --   dap_python.setup(python)
      -- end
      --
      -- -- ============================================================
      -- Go(delve)
      --  - leoluz/nvim-dap-go 플러그인이 기본 설정을 자동 적용
      --  - dlv 바이너리가 필요(수동 설치 또는 Go:InstallBinaries)
      -- ============================================================
      -- 추가 설정이 필요하면 여기서 require("dap-go").setup({ … })로 확장

      -- ============================================================
      -- Java(jdtls 연동)
      --  - jdtls가 기동되면 DAP도 함께 활성화되도록 설정
      --  - 프로젝트별 ftplugin/java.lua 등에서 jdtls.start_or_attach(...) 호출 필요
      -- ============================================================
      local ok_jdtls, jdtls = pcall(require, "jdtls")
      if ok_jdtls then
        -- 코드 변경 핫스왑: 'auto' (수정 시 자동 교체)
        jdtls.setup_dap({ hotcodereplace = "auto" })
        -- 참고: 실행/테스트 설정은 jdtls가 파일/프로젝트 구조를 인식해 동적으로 구성
      end
    end,
  },
}
