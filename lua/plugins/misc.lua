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
    end,
  },
}
