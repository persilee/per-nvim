-- lua/plugins/noice.lua
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  enabled = false,
  dependencies = {
    "MunifTanjim/nui.nvim", -- 必须
    "rcarriga/nvim-notify",
  },
  init = function()
    require("notify").setup({
      background_colour = "#1e1e2e",
    })
    -- 匹配 Catppuccin Mocha 背景色，其他口味替换对应色值即可
    vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#1e1e2e" })
  end,
  config = function()
    require("noice").setup({
      -- 命令行配置
      cmdline = {
        enabled = true, -- 启用 Noice 命令行
        view = "cmdline", -- 浮窗形式
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { pattern = "^/", icon = "", lang = "regex" },
          search_up = { pattern = "^%?", icon = "", lang = "regex" },
          lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
        },
      },

      messages = {
        enabled = true,
        view = "notify", -- 普通消息用状态栏mini模式，不打扰
        view_error = "popup", -- 错误消息用弹窗
        view_warn = "mini",
      },

      -- LSP 配置
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        progress = { enabled = false, view = "mini" },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false, view = "notify" },
      },

      notify = {
        enabled = true,
        view = "notify",
        background_colour = "#1e1e2e",
      },

      -- 过滤保存文件通知
      routes = {
        {
          filter = {
            event = "notify",
            kind = "warn",
            find = "Config Change Detected", -- 匹配包含的提示
          },
          opts = { skip = true }, -- 直接跳过，不显示也不记入历史
        },
        -- 外部命令(:!)输出用弹窗显示，不自动消失
        {
          filter = {
            event = "msg_show",
            kind = "shell",
          },
          view = "popup",
          opts = {
            enter = true, -- 打开弹窗自动聚焦，方便滚动查看长输出
            border = "single",
            size = { width = 0.8, height = 0.6 },
            position = "center",
          },
        },
      },

      -- 预设
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
        incognito = false,
      },
    })
  end,
  keys = {
    -- 查看完整通知历史
    {
      "<leader>nh",
      function()
        require("noice").cmd("history")
      end,
      desc = "通知：查看历史消息",
    },
    -- 快速查看最近一条通知
    {
      "<leader>nl",
      function()
        require("noice").cmd("last")
      end,
      desc = "通知：查看最近一条",
    },
    -- 只查看错误历史
    {
      "<leader>ne",
      function()
        require("noice").cmd("errors")
      end,
      desc = "通知：查看错误历史",
    },
    -- 清除所有悬浮通知
    {
      "<leader>nd",
      function()
        require("noice").cmd("dismiss")
      end,
      desc = "通知：清除所有通知",
    },
    -- 打开选择器搜索历史
    {
      "<leader>np",
      function()
        require("noice").cmd("pick")
      end,
      desc = "通知：搜索历史消息",
    },
  },
}
