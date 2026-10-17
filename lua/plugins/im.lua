-- lua/plugins/im.lua
-- 输入法自动切换（macOS）
-- 核心行为：
--   1. NORMAL 模式：始终保持英文输入法（默认 com.apple.keylayout.ABC）
--   2. INSERT 模式：自动恢复上次编辑时使用的输入法（中文/英文都记住）
--   3. 命令行（Cmdline）同理：进入恢复、离开回英文
-- 依赖：macism（macOS 输入法切换 CLI）
--   安装：brew tap laishulu/homebrew
--         brew install macism
--   验证：macism  查看你的输入法 ID
return {
  "keaising/im-select.nvim",
  lazy = false, -- 启动即加载，保证任何模式切换都生效
  opts = {
    default_im_select = "com.apple.keylayout.ABC", -- 英文输入法 ID（可用 macism --list 确认）
    default_command = "macism", -- macOS 输入法切换工具
  },
}
