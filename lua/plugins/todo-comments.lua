return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- 按键和命令触发时才加载插件
  keys = {
    {
      "]t",
      function()
        require("todo-comments").jump_next({ keywords = { "TODO", "FIXME", "HACK" } })
      end,
      desc = "下一个 Todo 注释",
    },
    {
      "[t",
      function()
        require("todo-comments").jump_prev({ keywords = { "TODO", "FIXME", "HACK" } })
      end,
      desc = "上一个 Todo 注释",
    },
  },
  cmd = {
    "TodoQuickFix",
    "TodoLocList",
    "TodoTelescope",
    "TodoFzfLua",
    "TodoTrouble",
  },
  opts = {
    signs = true, -- 行号列显示图标
    keywords = {
      FIX = {
        icon = " ",
        color = "error",
        alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
      },
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning" },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
    },
  },
}
