-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- lua/keymaps.lua
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- leader 键
vim.g.mapleader = " " -- 空格为 leader

-- 下一个 / 上一个 Tab
map("n", "<leader><PageDown>", ":BufferLineCycleNext<CR>", opts) -- 下一个 Tab
map("n", "<leader><PageUp>", ":BufferLineCyclePrev<CR>", opts) -- 上一个 Tab

-- 快速跳转到指定 Tab（1~9）
for i = 1, 9 do
  map("n", "<leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", opts)
end

-- 关闭当前 Tab
map("n", "<leader>c", function()
  -- 正常关闭，有未保存修改会弹出提示
  Snacks.bufdelete()
  -- 强制关闭（等价于原来的 !），直接丢弃修改
  -- Snacks.bufdelete({ force = true })
end, opts)

-- 分屏操作
map("n", "<leader><Left>", "<C-w>h", opts) -- 移动到左边窗口
map("n", "<leader><Down>", "<C-w>j", opts) -- 移动到下边窗口
map("n", "<leader><Up>", "<C-w>k", opts) -- 移动到上边窗口
map("n", "<leader><Right>", "<C-w>l", opts) -- 移动到右边窗口

-- 文件操作
map("n", "<leader>w", ":w<CR>", opts) -- 保存
map("n", "<leader>q", ":q<CR>", opts) -- 关闭
map("n", "<leader>Q", ":wq<CR>", opts) -- 关闭

-- 行移动
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
-- 调整窗口大小
vim.keymap.set("n", "<A-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<A-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<A-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<A-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- 在终端模式中按 Esc 直接退出到普通模式
map("t", "<Esc>", [[<C-\><C-n>]], opts)

-- 可选：兼容终端中使用 Ctrl+C（仅在 GUI 中安全，终端中慎用）
map("v", "<C-c>", [["+y]], opts)
map("n", "<C-c>", [["+yy]], opts)

-- 黏贴到当前光标位置
map("n", "<C-v>", [["+p]], opts)
map("v", "<C-v>", [["+p]], opts)
map("n", "p", [["+p]], opts)
map("v", "p", [["+p]], opts)

-- 文本选择与跳转：定义了快速选择文本和跳转的快捷键
-- vv: 选择到匹配的括号，vc: 选择当前单词，vl: 进入行选择模式
map("n", "vv", "v%", opts)
map("n", "vc", "viw", opts)
map("n", "vl", "V", opts)

-- 清除查找高亮
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- 打开一个浮动终端
-- local float_term = require("customs.float_trem")
-- map("n", "<leader>tf", float_term.open, opts)

-- 打开诊断窗口
map("n", "<leader>xx", ":Trouble diagnostics toggle<CR>", opts)

-- 在你的 keymaps.lua 中添加
map("v", "<Tab>", ">", opts)
map("v", "<S-Tab>", "<", opts) -- Shift+Tab 减少缩进

map("n", "<leader>e", ":Neotree toggle<CR>", opts)

-- 设置显示 / 不显示 tab
vim.keymap.set("n", "<leader>tb", function()
  if vim.o.showtabline == 0 then
    vim.o.showtabline = 2
  else
    vim.o.showtabline = 0
  end
end, { desc = "Toggle Bufferline" })

-- 普通模式下全选
map("n", "<C-a>", "gg0vG$", opts)

-- 删除当前单词
map("n", "dw", "diw", opts)
-- 搜索光标下的单词
map("n", "<C-f>", "*")

-- 一键设置光标样式+颜色
vim.keymap.set("n", "<leader>cc", function()
  vim.opt.guicursor = "n:block-Cursor"
  vim.api.nvim_set_hl(0, "Cursor", { fg = "#1e1e2e", bg = "#ff79c6" })
  vim.notify("光标已切换为粉色方块", vim.log.levels.INFO)
end, { desc = "设置光标为粉色方块样式", silent = true })
