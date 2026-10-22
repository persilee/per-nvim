return {
  -- 代码操作（Code Actions）可视化执行插件
  -- 相比 Lspsaga：更专注 code_action，支持 diff 预览（vim/delta/difftastic），兼容各类 LSP
  -- GitHub: https://github.com/rachartier/tiny-code-action.nvim
  "rachartier/tiny-code-action.nvim",

  -- LSP 连接时加载（按需）
  event = "LspAttach",

  opts = {
    -- diff 预览后端：vim（内置，无需额外安装）
    -- 其他可选：delta / difftastic / diffsofancy（需单独安装对应工具）
    backend = "vim",

    -- 选择器：用 snacks（与你的 UI 风格统一，已有 terminal 支持）
    -- 其他可选：telescope / fzf-lua / buffer / select
    picker = "snacks",

    -- 超时设置：解析 code actions 的最长等待（毫秒）
    resolve_timeout = 100,

    -- 通知设置
    notify = {
      enabled = true, -- 开启通知
      on_empty = true, -- 没有可用操作时提示
    },

    -- 动作标题格式化：显示标题 + 动作类型（如 "Add missing members (quickfix)"）
    -- format_title = function(action, client)
    --   if action.kind then
    --     return string.format("%s (%s)", action.title, action.kind)
    --   end
    --   return action.title
    -- end,

    -- 动作图标（Nerd Font），按 LSP action kind 区分
    signs = {
      quickfix = { "", { link = "DiagnosticWarning" } },
      others = { "", { link = "DiagnosticWarning" } },
      refactor = { "", { link = "DiagnosticInfo" } },
      ["refactor.move"] = { "󰪹", { link = "DiagnosticInfo" } },
      ["refactor.extract"] = { "", { link = "DiagnosticError" } },
      ["source.organizeImports"] = { "", { link = "DiagnosticWarning" } },
      ["source.fixAll"] = { "󰃢", { link = "DiagnosticError" } },
      ["source"] = { "", { link = "DiagnosticError" } },
      ["rename"] = { "󰑕", { link = "DiagnosticWarning" } },
      ["codeAction"] = { "", { link = "DiagnosticWarning" } },
    },
  },
}
