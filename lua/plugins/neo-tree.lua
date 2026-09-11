return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- 文件图标（可选但推荐）
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true, -- 如果是最后一个窗口，关闭 neo-tree 时退出 Neovim
        popup_border_style = "rounded",
        clipboard = {
          sync = "universal",
        },
        enable_git_status = true,                                          -- 显示 Git 状态（需安装 git）
        enable_diagnostics = true,                                         -- 显示 LSP 诊断错误/警告图标
        open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- 这些类型不被替换

        -- 文件系统源配置
        filesystem = {
          bind_to_cwd = true,            -- 不强制绑定到 cwd
          follow_current_file = {
            enabled = true,              -- 自动展开并聚焦当前文件
          },
          use_libuv_file_watcher = true, -- 使用 libuv 监听文件变化（无需手动刷新）
          filtered_items = {
            visible = true,              -- 显示隐藏文件（按 i 切换）
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_hidden = true, -- only works on Windows for hidden files/directories
            hide_by_name = {
              ".DS_Store",
              "thumbs.db",
              "__pycache__",
              --"node_modules",
            },
          },
        },

        -- 窗口 & 快捷键
        window = {
          position = "float", -- 左侧 sidebar
          width = 0.15,       -- 固定宽度
          mappings = {
            -- 每按一次 + 加宽 2 列
            ["+"] = function()
              vim.cmd("vertical resize +2")
            end,
            -- 每按一次 - 缩窄 2 列
            ["-"] = function()
              vim.cmd("vertical resize -2")
            end,
            -- 按 = 一键恢复默认宽度（数值改成你配置的默认宽度）
            ["="] = function()
              vim.cmd("vertical resize 30")
            end,
          },
        },

        -- 可选：启用 source selector（winbar 或 statusline）
        source_selector = {
          winbar = false,
          statusline = false,
        },
      })
    end,
  },
}
