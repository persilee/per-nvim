return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    indent = {
      enabled = false,

      -- 背景灰色普通缩进线
      indent = {
        priority = 1,
        enabled = true, -- enable indent guides
        char = "│",
        only_scope = false, -- only show indent guides of the scope
        only_current = false, -- only show indent guides in the current window
      },

      -- 当前所在代码块
      scope = {
        enabled = true, -- enable highlighting the current scope
        priority = 200,
        char = "│",
        underline = false, -- underline the start of the scope
        only_current = false, -- only show scope in the current window
        hl = "SnacksIndentScope", ---@type string|string[] hl group for scopes
      },
    },

    -- 替代telescope
    picker = {
      enabled = true,
      icons = {
        -- 开启持久化缓存，自动存到 Neovim 标准缓存目录
        cache = true,
        -- 只加载指定图标集，减少体积加快速度
        -- sources = { "nerd" }
      },
      win = {
        input = {
          keys = {
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            ["<Tab>"] = { "list_down", mode = { "i", "n" } },
          },
        },

        list = {
          keys = {
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            ["<Tab>"] = { "list_down", mode = { "i", "n" } },
          },
        },
      },
    },

    notifier = {
      enabled = false,
      timeout = 2000,
    },

    scope = { enabled = true },
    dashboard = { enabled = true },
    input = { enabled = true },
    animate = {},

    terminal = {
      enabled = true,
      -- 终端默认外观与行为
      win = {
        position = "bottom", -- 底部显示，可选 float/top/left/right
        height = 0.3, -- 占窗口高度的 30%
        border = "single",
      },
      auto_insert = true, -- 打开终端自动进入插入模式
      shell = "/bin/zsh", -- Mac 系统默认用 zsh
      -- 终端内自定义快捷键
      keys = {
        q = "hide", -- 终端内按 q 快速隐藏
        ["<C-l>"] = function(self)
          self:send("clear\r")
        end, -- Ctrl+l 清屏
        ["<Esc>"] = {
          function(self)
            self.esc_timer = self.esc_timer or vim.loop.new_timer()
            if self.esc_timer:is_active() then
              self.esc_timer:stop()
              vim.cmd("stopinsert") -- 双击：退出插入模式
            else
              self.esc_timer:start(200, 0, function() end)
              return "<Esc>" -- 单击：转发给终端
            end
          end,
          mode = "t",
          expr = true,
        },
      },
    },
  },

  keys = {
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader><space>",
      function()
        Snacks.picker.smart()
      end,
      desc = "智能查找",
    },
    {
      "<leader>ff",
      function()
        Snacks.picker.files()
      end,
      desc = "Find Files",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.grep()
      end,
      desc = "Find Grep",
    },
    {
      "<leader>fp",
      function()
        Snacks.picker.projects()
      end,
      desc = "Projects",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent",
    },
    {
      "<leader>:",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.search_history()
      end,
      desc = "Search History",
    },
    {
      "<leader>fh",
      function()
        Snacks.picker.help({ layout = "ivy_splitp" })
      end,
      desc = "查找帮助文档",
    },
    {
      "<leader>fl",
      function()
        Snacks.picker.picker_layouts()
      end,
      desc = "查找 picker 的所有布局",
    },
    {
      "<leader>fk",
      function()
        Snacks.picker.keymaps({ layout = "ivy_splitp" })
      end,
      desc = "查找快捷键",
    },
    {
      "<leader>sd",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "Diagnostics",
    },

    {
      "gd",
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = "Goto Definition",
    },
    {
      "gD",
      function()
        Snacks.picker.lsp_declarations()
      end,
      desc = "Goto Declaration",
    },
    {
      "gr",
      function()
        Snacks.picker.lsp_references()
      end,
      nowait = true,
      desc = "References",
    },
    {
      "gI",
      function()
        Snacks.picker.lsp_implementations()
      end,
      desc = "Goto Implementation",
    },
    {
      "gy",
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      desc = "Goto T[y]pe Definition",
    },
    {
      "<leader>gs",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Git Status",
    },
    {
      "<leader>gd",
      function()
        Snacks.picker.git_diff()
      end,
      desc = "Git Diff (Hunks)",
    },
    {
      "gai",
      function()
        Snacks.picker.lsp_incoming_calls()
      end,
      desc = "C[a]lls Incoming",
    },
    {
      "gao",
      function()
        Snacks.picker.lsp_outgoing_calls()
      end,
      desc = "C[a]lls Outgoing",
    },
    {
      "<leader>ss",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "LSP Symbols",
    },
    {
      "<leader>sS",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "LSP Workspace Symbols",
    },
    -- 🔹 切换底部默认终端（最常用）
    {
      "<leader>tt",
      function()
        Snacks.terminal()
      end,
      desc = "终端：切换底部终端",
    },
    -- 🔹 打开浮动终端
    {
      "<leader>tf",
      function()
        Snacks.terminal(nil, { win = { position = "float", width = 0.8, height = 0.8 } })
      end,
      desc = "终端：打开浮动终端",
    },
    -- 🔹 列出所有终端会话
    {
      "<leader>tl",
      function()
        Snacks.terminal.list()
      end,
      desc = "终端：列出所有会话",
    },
    -- 新建一个独立终端会话
    {
      "<leader>tn",
      function()
        Snacks.terminal.new()
      end,
      desc = "终端：新建会话",
    },
  },
}
