local tab_fg = "#282c34"
local tab_bg = "#61afef"

return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",

  opts = {
    options = {
      -- 数字显示：none（简洁）或 ordinal（1,2,3）
      numbers = "ordinal",

      themable = true,

      -- 自定义过滤规则，不显示无名称的空缓冲区
      custom_filter = function(buf_number)
        local bufname = vim.api.nvim_buf_get_name(buf_number)
        -- 过滤掉空名称的缓冲区
        if bufname == "" then return false end
        return true
      end,

      -- 关闭 buffer 的命令
      -- bufferline setup 内的 options 部分
      close_command = function(bufnr)
        -- 获取所有 buffer（仅限已列出并没有被隐藏的）
        local buffers = vim.tbl_filter(function(b)
          return vim.api.nvim_buf_get_option(b.bufnr, "buftype") == ""
              and vim.api.nvim_buf_get_option(b.bufnr, "buflisted")
        end, vim.fn.getbufinfo({ buflisted = 1 }))

        -- 如果有多个 buffer，删除当前 buffer
        if #buffers > 1 then
          vim.cmd("bdelete! " .. bufnr)
        else
          -- 如果只有一个 buffer，创建一个空 buffer
          vim.cmd("enew")
        end
      end,

      right_mouse_command = function(bufnr)
        -- force = true 等价于 !，不需要强制删除可去掉
        local Snacks = require("snacks")
        Snacks.bufdelete(bufnr, { force = false })
      end,

      -- 左键切换 buffer 保持原来的方式
      left_mouse_command = "buffer %d",

      -- 中键可以禁用
      middle_mouse_command = nil,

      -- 图标设置
      indicator_icon = "",
      buffer_close_icon = "✖",
      close_icon = "", -- 更柔和的关闭图标
      modified_icon = "●",
      show_buffer_close_icons = false,
      show_close_icon = false, -- 右上角大关闭按钮

      -- 分隔符样式：推荐 "thin" 或 "slant"
      separator_style = "thin", -- 也可以试试 "slant"

      -- 始终显示 tabline
      always_show_bufferline = true,

      -- tab 宽度
      tab_size = 16,

      -- 是否显示 tab 编号
      show_tab_indicators = false,

      diagnostics = "nvim_lsp",

      -- 配合侧边栏
      offsets = {
        {
          filetype = "neo-tree",
          text = "📂 Files",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },

    highlights = {
      -- 之前已有的透明配置
      fill = { bg = "NONE" },
      background = { bg = "NONE" },
      buffer_selected = { bg = "NONE", bold = true },
      buffer_visible = { bg = "NONE" },
      separator = { bg = "NONE" },
      separator_selected = { bg = "NONE" },
      close_button = { bg = "NONE" },
      close_button_selected = { bg = "NONE" },
      offset_separator = { bg = "NONE" },

      -- 新增：序号数字透明（核心修复）
      numbers = { bg = "NONE" },          -- 未选中标签的序号
      numbers_selected = { bg = "NONE" }, -- 选中标签的序号
      numbers_visible = { bg = "NONE" },  -- 可见但未选中标签的序号

      -- 可选：选中指示器也透明（如果左边竖线还有背景）
      indicator_selected = { bg = "NONE" },
    },
  },
}
