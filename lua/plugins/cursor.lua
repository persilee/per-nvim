return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      -- Add or skip cursor above/below the main cursor.
      set({ "n", "x" }, "<up>", function()
        mc.lineAddCursor(-1)
      end)
      set({ "n", "x" }, "<down>", function()
        mc.lineAddCursor(1)
      end)
      set({ "n", "x" }, "<leader><up>", function()
        mc.lineSkipCursor(-1)
      end)
      set({ "n", "x" }, "<leader><down>", function()
        mc.lineSkipCursor(1)
      end)

      -- Add or skip adding a new cursor by matching word/selection
      set({ "n", "x" }, "<leader>n", function()
        mc.matchAddCursor(1)
      end)
      set({ "n", "x" }, "<leader>s", function()
        mc.matchSkipCursor(1)
      end)
      set({ "n", "x" }, "<leader>N", function()
        mc.matchAddCursor(-1)
      end)
      set({ "n", "x" }, "<leader>S", function()
        mc.matchSkipCursor(-1)
      end)

      -- Add and remove cursors with control + left click.
      set("n", "<c-leftmouse>", mc.handleMouse)
      set("n", "<c-leftdrag>", mc.handleMouseDrag)
      set("n", "<c-leftrelease>", mc.handleMouseRelease)

      -- Disable and enable cursors.
      set({ "n", "x" }, "<c-q>", mc.toggleCursor)

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)

        -- Delete the main cursor.
        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
  },
  {
    "vscode-neovim/vscode-multi-cursor.nvim",
    event = "VeryLazy",
    cond = not not vim.g.vscode,
    opts = {},
  },
  {
    "sphamba/smear-cursor.nvim",

    opts = {
      -- ========== 核心动画参数（解决抖动最关键） ==========
      -- 光标头部跟随速度：越高越跟手，太高会生硬
      stiffness = 0.7,
      -- 光标尾部跟随速度：越高拖尾越短，抖动越少
      trailing_stiffness = 0.5,
      -- 阻尼系数：越高越无回弹、越丝滑；默认0.85偏低会抖
      damping = 0.90,
      -- 插入模式下的阻尼，同样调高避免插入时抖
      damping_insert_mode = 0.90,
      -- 动画停止阈值：大于0.3就基本不会微颤，默认0.1太小
      distance_stop_animating = 0.3,

      -- ========== 帧率优化（解决卡顿式抖动） ==========
      -- 绘制间隔，默认17ms（约60帧），调低到7ms提升流畅度
      time_interval = 7,

      -- ========== 版本兼容修复（解决命令模式后抖一下） ==========
      -- Neovim 0.11.x 必须加，修复退出命令行后光标瞬移抖动
      delay_event_to_smear = 10,

      -- ========== 可选优化 ==========
      -- 关闭跨缓冲区动画，减少不必要的大幅跳动
      smear_between_buffers = true,
      -- 关闭命令行的 smear，避免命令行光标异常
      smear_to_cmd = true,
      smear_insert_mode = true,
    },
  },
}
