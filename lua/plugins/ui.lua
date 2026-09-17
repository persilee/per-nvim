return {
  -- 状态栏
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    enabled = false,
    opts = function()
      --- nvimpire 主题对应色值（Dracula 色系）
      local c = {
        purple = "#bd93f9",
        green = "#50fa7b",
        orange = "#ffb86c",
        red = "#ff5555",
        yellow = "#f1fa8c",
        cyan = "#8be9fd",
        fg = "#f8f8f2",
      }

      local transparent_theme = {
        normal = {
          a = { fg = c.purple, bg = "NONE", gui = "bold" },
          b = { fg = c.fg, bg = "NONE" },
          c = { fg = c.fg, bg = "NONE" },
        },
        insert = {
          a = { fg = c.green, bg = "NONE", gui = "bold" },
          b = { fg = c.fg, bg = "NONE" },
          c = { fg = c.fg, bg = "NONE" },
        },
        visual = {
          a = { fg = c.orange, bg = "NONE", gui = "bold" },
          b = { fg = c.fg, bg = "NONE" },
          c = { fg = c.fg, bg = "NONE" },
        },
        replace = {
          a = { fg = c.red, bg = "NONE", gui = "bold" },
          b = { fg = c.fg, bg = "NONE" },
          c = { fg = c.fg, bg = "NONE" },
        },
        command = {
          a = { fg = c.yellow, bg = "NONE", gui = "bold" },
          b = { fg = c.fg, bg = "NONE" },
          c = { fg = c.fg, bg = "NONE" },
        },
        terminal = {
          a = { fg = c.cyan, bg = "NONE", gui = "bold" },
          b = { fg = c.fg, bg = "NONE" },
          c = { fg = c.fg, bg = "NONE" },
        },
      }

      return {
        options = {
          theme = transparent_theme,
          icons_enabled = true,
          -- 透明背景下推荐用直线分隔符，去掉默认斜角避免色块残留
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
      }
    end,
  },

  -- 语法高亮 & Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate", -- lazy.nvim 里用 build，不是 run
    opts = {
      ensure_installed = { "c", "cpp", "lua", "python", "cmake" }, -- 必装语言
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = { enable = true },
      folds = { enable = true },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
  },
}
