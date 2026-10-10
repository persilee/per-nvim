return {
  -- Git 集成
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "打开 LazyGit" },
    },
  },

  -- 自动括号匹配
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true, -- 启用 Treesitter 检测语言
        enable_check_bracket_line = true, -- 同一行避免重复括号
      })

      -- -- 集成 nvim-cmp
      -- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      -- local cmp = require("cmp")
      -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- 输入加强：
  -- ysiw" - 给当前单词加双引号
  -- yss" - 给整行加双引号
  -- ds" - 删除光标附近的双引号
  -- cs"' - 双引号改单引号等
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- 字符跳转增强
  {
    "smoka7/hop.nvim",
    version = "*", -- 锁定稳定版
    event = "VeryLazy",
    enabled = false,
    config = function()
      require("hop").setup({
        -- 提示标签的字符顺序（按键盘指法优先排列）
        keys = "etovxqpdygfblzhckisuran",
        -- 搜索时不区分大小写
        case_insensitive = true,
        -- 是否跨所有分割窗口跳转
        multi_windows = false,
        -- 只剩一个匹配目标时自动跳转，无需按标签
        jump_on_sole_occurrence = false,
      })

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- 1. 双字符精准跳转（主力推荐，重名率极低）
      -- 普通/可视/操作符待决模式通用，可配合 d/c/y 使用
      map({ "n", "o", "v" }, "<leader>js", "<cmd>HopChar2<cr>", opts)

      -- 2. 单字符全局跳转（替代原生 f，支持跨多行）
      map({ "n", "o", "v" }, "<leader>jf", "<cmd>HopChar1<cr>", opts)

      -- 3. 仅当前行内反向单字符跳转（模拟原生 F 行为）
      map({ "n", "o", "v" }, "<leader>jF", "<cmd>HopChar1CurrentLineBC<cr>", opts)

      -- 4. 跳转到任意行开头
      map("n", "<leader>jl", "<cmd>HopLine<cr>", { desc = "Hop 跳转到行" })

      -- 5. 跳转到任意单词开头
      map("n", "<leader>jw", "<cmd>HopWord<cr>", { desc = "Hop 跳转到单词" })

      -- 6. 正则匹配跳转
      map("n", "<leader>jp", "<cmd>HopPattern<cr>", { desc = "Hop 正则跳转" })
    end,
  },

  -- 一键注释
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup({
        -- 默认配置已经很方便
        toggler = {
          line = "gcc", -- 切换行注释
          block = "gbc", -- 切换块注释
        },
        opleader = {
          line = "gc", -- 可视模式操作行注释
          block = "gb", -- 可视模式操作块注释
        },
        mappings = {
          basic = true, -- 启用基本映射
          extra = true, -- gco/gcO 额外映射
        },
      })
      -- 修复：Neovim 0.12 对无 treesitter parser 的文件（如 .conf）
      -- `get_parser` 返回 nil 而非报错，导致 Comment.nvim 内部
      -- ft.contains(nil) 崩溃（报 [Comment.nvim] nil 警告），gcc 注释无效。
      -- 这里在 parser 无效时回退到 filetype 的静态注释符映射。
      local ft = require("Comment.ft")
      local orig_calculate = ft.calculate
      ---@diagnostic disable-next-line: duplicate-set-field
      ft.calculate = function(ctx)
        local ok, parser = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
        if not ok or not parser then
          return ft.get(vim.bo.filetype, ctx.ctype)
        end
        return orig_calculate(ctx)
      end
    end,
  },

  -- 彩虹括号：不同层级括号不同颜色（treesitter 实现）
  -- 圆括号/方括号/花括号分层着色，颜色自动跟随 colorscheme
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("rainbow-delimiters.setup").setup({})

      -- 主题适配：gradient_dracula 等主题未定义 RainbowDelimiter* 高亮组，
      -- 插件会 fallback 到内置默认色导致颜色怪异。
      -- 这里从当前主题的语义高亮组提取颜色，保证与主题配色一致。
      local function fg(name, fallback)
        local hl = vim.api.nvim_get_hl(0, { name = name })
        return hl.fg or fallback
      end
      local rainbow = {
        RainbowDelimiterRed = "#ff79c6",
        RainbowDelimiterYellow = fg("DiagnosticWarn", "#f9e2af"),
        RainbowDelimiterBlue = fg("DiagnosticInfo", "#89b4fa"),
        RainbowDelimiterOrange = fg("DiagnosticWarn", "#fab387"),
        RainbowDelimiterGreen = fg("DiagnosticOk", "#a6e3a1"),
        RainbowDelimiterViolet = fg("Statement", "#cba6f7"),
        RainbowDelimiterCyan = fg("Constant", "#94e2d5"),
      }
      for group, color in pairs(rainbow) do
        vim.api.nvim_set_hl(0, group, { fg = color })
      end
    end,
  },
}
