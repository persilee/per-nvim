return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    keys = {
      -- 核心匹配操作
      { "<leader>mn", mode = { "n", "x" }, "<Plug>(VM-Find-Under)", desc = "多光标：选中下一个匹配项" },
      { "<leader>mp", mode = { "n", "x" }, "<Plug>(VM-Find-Prev)", desc = "多光标：选中上一个匹配项" },
      {
        "<leader>ma",
        mode = { "n", "x" },
        "<Plug>(VM-Find-Under)<Plug>(VM-Select-All)",
        desc = "多光标：全选所有匹配项",
      },

      -- 光标管理
      { "<leader>ms", mode = "n", "<Plug>(VM-Skip-Region)", desc = "多光标：跳过当前匹配项" },
      { "<leader>mr", mode = "n", "<Plug>(VM-Remove-Region)", desc = "多光标：移除当前光标" },
      { "<leader>mq", mode = "n", "<Plug>(VM-Exit)", desc = "多光标：退出多光标模式" },

      -- 垂直逐行添加光标（列编辑场景）
      { "<M-S-j>", mode = "n", "<Plug>(VM-Add-Cursor-Down)", desc = "多光标：向下添加一行光标" },
      { "<M-S-k>", mode = "n", "<Plug>(VM-Add-Cursor-Up)", desc = "多光标：向上添加一行光标" },

      -- 模式切换
      { "<leader>mt", mode = "n", "<Plug>(VM-Toggle-Mode)", desc = "多光标：切换扩展/光标模式" },
    },
    init = function()
      -- 关闭默认映射，自定义快捷键
      vim.g.VM_default_mappings = 0
      -- 适配 Catppuccin 风格的配色主题
      vim.g.VM_theme = "dracula"
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
      smear_between_buffers = false,
      -- 关闭命令行的 smear，避免命令行光标异常
      smear_to_cmd = false,
    },
  },
}
