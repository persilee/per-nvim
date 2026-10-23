return {
  -- Supermaven：项目级 AI 补全（索引整个项目，理解跨文件依赖）
  -- 原生行内（inline）模式：渐进式补全，接受后自动续写下一段（Cursor Tab 体验）
  -- GitHub: https://github.com/supermaven-inc/supermaven-nvim
  "supermaven-inc/supermaven-nvim",

  event = "InsertEnter", -- 进入插入模式时加载

  opts = {
    -- inline 补全保持默认开启（渐进式体验的核心）
    -- disable_inline_completion 不设置（保持 false）

    -- 禁用自带按键：Tab 接受由 keymaps.lua 统一处理（避免与 blink 菜单冲突）
    disable_keymaps = true,

    -- 忽略的文件类型（示例：不想在 shell 脚本里补全就取消注释）
    -- ignore_filetypes = { sh = true },

    -- 建议文本颜色（可选，默认跟随主题）
    -- color = { suggestion_color = "#6c7086", cterm = 244 },

    log_level = "info", -- 日志级别（"off" 可完全关闭日志）
  },
}
