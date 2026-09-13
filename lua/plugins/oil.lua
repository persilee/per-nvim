local detail = false

-- 先定义全局 winbar 生成函数
_G.get_oil_winbar = function()
  local ok, oil = pcall(require, "oil")
  if not ok then
    return ""
  end

  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = oil.get_current_dir(bufnr)

  if dir then
    -- 把绝对路径简化成 ~ 开头的形式
    local short_path = vim.fn.fnamemodify(dir, ":~")
    -- 加文件夹图标前缀，适配 mini.icons 风格
    return "   " .. short_path
  else
    -- 远程目录（SSH）等特殊场景显示缓冲区名
    return " 🌐  " .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
  end
end

return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = { "nvim-mini/mini.icons" }, -- 文件图标（需要Nerd字体，Sarasa Term SC Nerd正好）
  keys = {
    {
      "-",
      function()
        require("oil").open()
      end,
      desc = "Oil: Open parent dir",
    },
    {
      "<leader>e",
      function()
        require("oil").open()
      end,
      desc = "Oil: Open parent dir",
    },
  },
  opts = {
    -- 简单自定义
    default_file_explorer = true, -- 接管目录buffer，nvim . 直接打开oil
    view_options = {
      show_hidden = false, -- 默认不显示隐藏文件 g. 切换
    },
    columns = {
      "icon",
    },
    -- Oil 缓冲区内部快捷键
    keymaps = {
      ["<C-h>"] = false,
      ["<C-l>"] = false,
      ["<C-k>"] = false,
      ["<C-j>"] = false,
      ["<C-r>"] = "actions.refresh",
      ["<leader>y"] = "actions.yank_entry",
      ["g."] = false,
      ["zh"] = "actions.toggle_hidden",
      ["\\"] = { "actions.select", opts = { horizontal = true } },
      ["|"] = { "actions.select", opts = { vertical = true } },
      ["-"] = "actions.close",
      ["<leader>e"] = "actions.close",
      ["<BS>"] = "actions.parent",
      ["gd"] = {
        desc = "Toggle file detail view",
        callback = function()
          detail = not detail
          if detail then
            require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
          else
            require("oil").set_columns({ "icon" })
          end
        end,
      },
      ["q"] = "actions.close", -- 按 q 直接关闭 Oil 窗口
    },

    -- ✅ 启用顶部路径标题栏
    win_options = {
      winbar = "%!v:lua.get_oil_winbar()",
    },
  },
}
