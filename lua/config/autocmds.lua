-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
    local hl_groups = {
      "Normal",
      "NormalNC",
      "NormalFloat",
      "SignColumn",
      "StatusLine",
      "StatusLineNC",
      "VertSplit",
      "TabLine",
      "TabLineFill",
      "TabLineSel",
      "Pmenu",
      "PmenuSel",
      "NeoTreeNormal",
      "NeoTreeNormalNC",
      "NeoTreeWinSeparator",
      "TelescopeNormal",
      "TelescopeBorder",
    }

    for _, group in ipairs(hl_groups) do
      vim.cmd(string.format("highlight %s guibg=NONE ctermbg=NONE", group))
    end

    local transparent_groups = {
      -- 需要透明的 bufferline 高亮组
      "BufferLineFill",
      "BufferLineBackground",
      "BufferLineBufferSelected",
      "BufferLineBufferVisible",
      "BufferLineSeparator",
      "BufferLineSeparatorSelected",
      "BufferLineCloseButton",
      "BufferLineCloseButtonSelected",
      "BufferLineTab",
      "BufferLineTabSelected",
      "BufferLineOffsetSeparator",
      -- 侧边栏与行号
      "LineNr",
      "CursorLineNr",
      "SignColumn",
      -- 命令与消息区
      "CmdLine",
      "MsgArea",
      -- 分屏与标签
      "WinSeparator",
      "VertSplit",
      "TabLine",
      "TabLineFill",
      "TabLineSel",
      -- 新增：状态栏核心（解决lualine不透明的关键）
      "StatusLine",
      "StatusLineNC", -- 非活动窗口状态栏
      "StatusLineTerm",
      "StatusLineTermNC",

      -- 新增：lualine 各模式分区背景（兜底覆盖）
      "LuaLineNormal",
      "LuaLineInsert",
      "LuaLineVisual",
      "LuaLineReplace",
      "LuaLineCommand",
      "LuaLineTerminal",
    }
    for _, group in ipairs(transparent_groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE" })
    end

    -- 单独保留选中标签的加粗效果
    vim.api.nvim_set_hl(0, "BufferLineBufferSelected", {
      bg = "NONE",
      bold = true,
    })

   -- 可选：光标行的行号强化（和普通行号区分）
    vim.api.nvim_set_hl(0, "CursorLineNr", {
      fg = "#FF79C6", -- 行号颜色，用主题强调色
      bg = "NONE",    -- 行号背景保持透明
      bold = true,
    })
    
    -- ===== 新增：修改注释颜色 =====
    vim.api.nvim_set_hl(0, "Comment", {
      fg = "#b2bbc2",  -- 注释主色，推荐柔紫色，适配粉色系主题
      italic = true,    -- 保留斜体，不需要就设为 false
      bold = false,     -- 不加粗
    })

    -- 可选：Treesitter 语义注释兜底（大部分情况自动继承 Comment，不生效再加）
    vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    vim.defer_fn(function()
      vim.opt.guicursor = "n-v-c:block-Cursor,i-ci:ver25-CursorInsert,r-cr:hor20-CursorReplace"
      -- ===== 新增：光标本身颜色 =====
      vim.api.nvim_set_hl(0, "Cursor", { fg = "#1e1e2e", bg = "#FF79C6" })        -- 普通模式光标
      vim.api.nvim_set_hl(0, "CursorInsert", { fg = "#1e1e2e", bg = "#50fa7b" })  -- 插入模式光标
      vim.api.nvim_set_hl(0, "CursorReplace", { fg = "#1e1e2e", bg = "#bd93f9" }) -- 替换模式光标
    end, 100)
  end,
})

-- 在主题加载后设置自定义高亮
local C = require("colors.color1")
local function apply_custom_highlights()
  -- 💠 设置透明补全菜单
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })                            -- 所有浮窗透明
  vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE", blend = 0 })                       -- 补全菜单透明
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = C.pink, fg = C.surface0, bold = true }) -- 选中项
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = C.ice_white, bg = "NONE" })          -- 边框保留

  vim.api.nvim_set_hl(0, "CurSearch", {
    bg = C.mint_cream,
    fg = C.surface0,
    bold = true,
  }) -- 搜索当前项

  -- ✨ Visual 模式选中区域
  -- vim.api.nvim_set_hl(0, "Visual", {
  --   bg = C.pink,
  --   fg = C.surface0,
  --   bold = true,
  -- })
end

-- 应用高亮
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = apply_custom_highlights,
})
