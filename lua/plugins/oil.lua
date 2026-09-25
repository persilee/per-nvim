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
      -- 禁用默认 Ctrl+h 快捷键
      -- Oil 默认该键用于窗口导航/返回父目录，这里禁用避免和终端、窗口移动类快捷键冲突
      ["<C-h>"] = false,

      -- 禁用默认 Ctrl+l 快捷键
      -- Oil 默认该键用于刷新/进入目录，这里禁用避免和清屏、窗口向右移动等快捷键冲突
      ["<C-l>"] = false,

      -- 禁用默认 Ctrl+k 快捷键
      -- Oil 默认该键用于向上移动光标/窗口导航，禁用防止和其他插件快捷键冲突
      ["<C-k>"] = false,

      -- 禁用默认 Ctrl+j 快捷键
      -- Oil 默认该键用于向下移动光标/窗口导航，禁用防止和其他插件快捷键冲突
      ["<C-j>"] = false,

      -- 绑定 Ctrl+r 为「刷新当前目录」，重新加载当前路径的文件列表
      ["<C-r>"] = "actions.refresh",

      -- 绑定 <leader>y 为「复制当前条目名」，将选中的文件/目录名复制到寄存器
      ["<leader>y"] = "actions.yank_entry",

      -- 禁用默认的 g. 快捷键
      -- Oil 默认 g. 是切换显示/隐藏隐藏文件，这里禁用，改用下面的 zh 实现相同功能
      ["g."] = false,

      -- 绑定 zh 为「切换隐藏文件显示」，替代默认的 g.
      -- 采用 z 前缀更符合 Vim 原生折叠/显示类操作的肌肉记忆
      ["zh"] = "actions.toggle_hidden",

      -- 绑定反斜杠 \ 键：选中文件后，以「水平分屏（左右）」方式打开
      -- actions.select 是打开文件的内置动作，horizontal = true 指定分屏方向
      ["\\"] = { "actions.select", opts = { horizontal = true } },

      -- 绑定竖线 | 键（Shift+\）：选中文件后，以「垂直分屏（上下）」方式打开
      ["|"] = { "actions.select", opts = { vertical = true } },

      -- 绑定 - 键为「关闭 Oil 窗口」
      -- 注意：Oil 默认 - 是返回上一级目录，这里被用户改成了关闭窗口的功能
      ["-"] = "actions.close",

      -- 绑定 <leader>e 为「关闭 Oil 窗口」，和 - 功能重复，提供两种操作方式
      ["<leader>e"] = "actions.close",

      -- 绑定退格键 Backspace 为「返回上一级父目录」，符合主流文件浏览器操作直觉
      ["<BS>"] = "actions.parent",

      -- 自定义 gd 快捷键：切换文件详情列的显示模式
      ["gd"] = {
        desc = "Toggle file detail view", -- 快捷键描述，会自动显示在 which-key 中
        callback = function()
          detail = not detail -- 切换详情开关状态
          if detail then
            -- 开启详情：显示 图标、权限、文件大小、修改时间 四列
            require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
          else
            -- 关闭详情：只显示图标一列，极简视图
            require("oil").set_columns({ "icon" })
          end
        end,
      },

      -- 🔹 返回 Oil 项目根目录（替代默认的 ~ 键，符合 g 前缀导航习惯）
      ["gr"] = function()
        vim.cmd("OilRoot")
      end,

      -- 🔹 跳转到 Neovim 当前工作目录（cwd）
      ["gc"] = "actions.open_cwd",

      -- 可选：一键跳转到系统根目录 /（自定义回调）
      ["g/"] = function()
        require("oil").open("/")
      end,

      ["q"] = "actions.close", -- 按 q 直接关闭 Oil 窗口
    },

    -- ✅ 启用顶部路径标题栏
    win_options = {
      winbar = "%!v:lua.get_oil_winbar()",
    },
  },

  config = function(_, opts)
    require("oil").setup(opts)

    -- 预览分屏时固定 oil 目录树宽度（oil 预览默认 50/50 分屏，这里改成窄栏）
    vim.api.nvim_create_autocmd("WinNew", {
      callback = function()
        vim.defer_fn(function()
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "oil" then
              vim.api.nvim_win_set_width(win, 36) -- oil 目录树固定 30 列
              vim.wo[win].winfixwidth = true -- 锁定宽度，不被均分
            end
          end
        end, 10)
      end,
    })
  end,
}
