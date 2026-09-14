return {
  {
    "rebelot/heirline.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    event = "VeryLazy",

    config = function()
      vim.opt.showmode = false
      vim.opt.shortmess:append("W")

      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*",
        callback = function(args)
          local bufnr = args.buf
          -- 标记当前缓冲区已保存
          vim.b[bufnr].saved = true
          -- 立即强制重绘状态栏
          vim.cmd("redrawstatus")
          -- 2 秒后自动隐藏
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              vim.b[bufnr].saved = false
              vim.cmd("redrawstatus")
            end
          end, 2000) -- 显示时长，单位毫秒
        end,
      })

      local heirline = require("heirline")
      local conditions = require("heirline.conditions")
      local utils = require("heirline.utils")

      local catppuccin_mocha = {
        blue = "#89b4fa",
        green = "#a6e3a1",
        mauve = "#cba6f7",
        peach = "#fab387",
        red = "#f38ba8",
        teal = "#94e2d5",
        pink = "#f5c2e7",
        text = "#cdd6f4",
        base = "#1e1e2e",
      }

      -- 从当前颜色主题自动提取配色，完美适配
      local colors = {
        bg = utils.get_highlight("StatusLine").bg,
        fg = utils.get_highlight("StatusLine").fg,
        blue = utils.get_highlight("DiagnosticInfo").fg,
        green = utils.get_highlight("DiagnosticOk").fg,
        purple = utils.get_highlight("Statement").fg,
        orange = utils.get_highlight("DiagnosticWarn").fg,
        red = utils.get_highlight("DiagnosticError").fg,
        yellow = utils.get_highlight("DiagnosticWarn").fg,
      }

      -- ========== 工具函数 ==========
      local function get_mode_color()
        local mode = vim.fn.mode()
        local mode_map = {
          n = catppuccin_mocha.blue,
          i = catppuccin_mocha.green,
          v = catppuccin_mocha.mauve,
          V = catppuccin_mocha.mauve,
          ["\22"] = catppuccin_mocha.mauve, -- 可视块模式
          c = catppuccin_mocha.peach,
          s = catppuccin_mocha.pink,
          S = catppuccin_mocha.pink,
          ["\19"] = catppuccin_mocha.pink, -- 选择块模式
          R = catppuccin_mocha.red,
          r = catppuccin_mocha.red,
          ["!"] = catppuccin_mocha.red,
          t = catppuccin_mocha.teal,
        }
        return mode_map[mode] or catppuccin_mocha.blue
      end

      -- ========== 1. 模式指示器（文字版） ==========
      local Mode = {
        init = function(self)
          self.mode = vim.fn.mode(1)
        end,
        provider = function(self)
          local mode_text = {
            n = " NORMAL ",
            i = " INSERT ",
            v = " VISUAL ",
            V = " V-LINE ",
            ["\22"] = " V-BLOCK ",
            c = " COMMAND ",
            s = " SELECT ",
            S = " S-LINE ",
            ["\19"] = " S-BLOCK ",
            R = " REPLACE ",
            r = " REPLACE ",
            ["!"] = " SHELL ",
            t = " TERMINAL ",
          }
          return mode_text[self.mode] or (" " .. self.mode:upper() .. " ")
        end,
        hl = function()
          return { bg = get_mode_color(), fg = catppuccin_mocha.base, bold = true }
        end,
        update = { "ModeChanged", pattern = "*:*" },
      }

      -- ========== 2. Git 分支 ==========
      local GitBranch = {
        condition = conditions.is_git_repo,
        init = function(self)
          self.status_dict = vim.b.gitsigns_status_dict
          self.branch = self.status_dict and self.status_dict.head
        end,
        provider = function(self)
          return "  " .. self.branch .. " "
        end,
        hl = { fg = colors.orange, bold = true },
        update = { "User", pattern = "GitSignsUpdate" },
      }

      -- ========== 3. 文件信息 + mini.icons 图标 ==========
      local FileIcon = {
        init = function(self)
          local filename = vim.api.nvim_buf_get_name(0)
          self.filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
          self.icon, self.icon_hl = require("mini.icons").get("file", self.filename)
        end,
        provider = function(self)
          return " " .. self.icon .. " "
        end,
        hl = function(self)
          -- 把高亮组名转换为实际颜色值，heirline 不接受直接传高亮组
          local ok, hl_props = pcall(require("heirline.utils").get_highlight, self.icon_hl)
          if ok and hl_props.fg then
            return { fg = hl_props.fg }
          end
          -- 异常 fallback 到默认文本色，避免报错
          return { fg = catppuccin_mocha.text }
        end,
        update = { "BufEnter", "BufFilePost" },
      }

      local FileName = {
        init = function(self)
          local filename = vim.api.nvim_buf_get_name(0)
          self.filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
        end,
        provider = function(self)
          return self.filename .. " "
        end,
        hl = { fg = catppuccin_mocha.text },
        update = { "BufEnter", "BufFilePost" },
      }

      local ModifiedDot = {
        condition = function()
          return vim.bo.modified
        end,
        provider = "● ",
        hl = { fg = catppuccin_mocha.pink, bold = true },
        -- 状态变化时自动刷新
        update = { "BufModifiedSet", "BufWritePost", "BufEnter" },
      }

      -- ========== 保存状态指示器 ==========
      local SaveStatus = {
        condition = function()
          return vim.b.saved == true
        end,
        provider = " ✓ Saved ",
        hl = { fg = catppuccin_mocha.green, bold = true },
        -- 明确指定触发更新的事件
        update = { "BufWritePost", "BufEnter" },
      }

      -- 组合成完整文件信息组件
      local FileInfo = { FileIcon, FileName, ModifiedDot }

      -- ========== 4. Git diff 状态 ==========
      local GitDiff = {
        condition = conditions.is_git_repo,
        init = function(self)
          self.status_dict = vim.b.gitsigns_status_dict
        end,
        {
          provider = function(self)
            local count = self.status_dict and self.status_dict.added or 0
            return count > 0 and (" +" .. count) or ""
          end,
          hl = { fg = colors.green },
        },
        {
          provider = function(self)
            local count = self.status_dict and self.status_dict.changed or 0
            return count > 0 and (" ~" .. count) or ""
          end,
          hl = { fg = colors.orange },
        },
        {
          provider = function(self)
            local count = self.status_dict and self.status_dict.removed or 0
            return count > 0 and (" -" .. count) or ""
          end,
          hl = { fg = colors.red },
        },
        update = { "User", pattern = "GitSignsUpdate" },
      }

      -- ========== 5. 诊断信息 ==========
      local Diagnostics = {
        condition = conditions.has_diagnostics,
        init = function(self)
          self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
          self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
          self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,
        {
          provider = function(self)
            return self.errors > 0 and (" ✗ " .. self.errors) or ""
          end,
          hl = { fg = colors.red },
        },
        {
          provider = function(self)
            return self.warnings > 0 and (" ▲ " .. self.warnings) or ""
          end,
          hl = { fg = colors.yellow },
        },
        {
          provider = function(self)
            return self.info > 0 and (" ● " .. self.info) or ""
          end,
          hl = { fg = colors.blue },
        },
        update = { "DiagnosticChanged", "BufEnter" },
      }

      -- ========== 6. 弹性工作目录（对应原 WorkDir 逻辑） ==========
      local WorkDir = {
        init = function(self)
          local cwd = vim.fn.getcwd(0)
          self.cwd = vim.fn.fnamemodify(cwd, ":~")
        end,
        hl = { fg = colors.fg, bold = true },
        flexible = 1,
        {
          -- 空间充足：显示完整路径
          provider = function(self)
            local trail = self.cwd:sub(-1) == "/" and "" or "/"
            return "   " .. self.cwd .. trail .. " "
          end,
        },
        {
          -- 空间不足：自动缩短路径
          provider = function(self)
            local short = vim.fn.pathshorten(self.cwd)
            local trail = self.cwd:sub(-1) == "/" and "" or "/"
            return "   " .. short .. trail .. " "
          end,
        },
        {
          -- 空间极小：自动隐藏
          provider = "",
        },
        update = { "DirChanged" },
      }

      -- ========== 7. 左右填充对齐 ==========
      local Align = { provider = "%=", hl = { bg = colors.bg } }

      -- ========== 8. LSP 状态 ==========
      local LSP = {
        condition = conditions.lsp_attached,
        provider = function()
          local names = {}
          for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
            table.insert(names, server.name)
          end
          return " " .. table.concat(names, ", ") .. " "
        end,
        hl = { fg = colors.green },
        update = { "LspAttach", "LspDetach", "BufEnter" },
      }

      -- ========== 9. 光标位置 ==========
      local Ruler = {
        provider = " %l:%c ",
        hl = { fg = colors.fg, bold = true },
      }

      -- ========== 组装完整状态栏 ==========
      local StatusLine = {
        hl = { fg = colors.fg, bg = colors.bg },
        Mode,
        GitBranch,
        FileInfo,
        SaveStatus,
        GitDiff,
        Diagnostics,
        WorkDir,
        Align,
        LSP,
        Ruler,
      }

      -- ========== 加载配置 ==========
      heirline.setup({
        statusline = StatusLine,
      })
    end,
  },
}
