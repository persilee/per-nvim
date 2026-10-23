return {
  "saghen/blink.cmp",
  -- optional: provides snippets for the snippet source
  dependencies = {
    "rafamadriz/friendly-snippets",
    "onsails/lspkind-nvim",
    "nvim-mini/mini.icons",
    "L3MON4D3/LuaSnip",
    "Kurama622/llm.nvim", -- llm.nvim 代码补全（blink 前端 source，改手动触发）
  },

  -- use a release tag to download pre-built binaries
  version = "1.*",
  opts = {
    keymap = {
      preset = "none",

      ["<Tab>"] = {
        function(cmp)
          -- 1. blink 菜单可见 → 优先操作菜单（选择下一项）
          if cmp.is_visible() then
            return cmp.select_next()
          end

          -- 2. 无菜单时：接受 Supermaven 行内建议（渐进式补全）
          -- 注意：须 vim.schedule 延迟执行——blink keymap 回调上下文中不允许改文本（E565）
          local ok, suggestion = pcall(require, "supermaven-nvim.completion_preview")
          if ok and suggestion.has_suggestion() then
            vim.schedule(function()
              suggestion.on_accept_suggestion()
            end)
            return true -- 已处理，阻止 fallback 插入 Tab
          end

          -- 3. 如果处于 snippet 编辑状态，跳转到下一个占位符
          if cmp.snippet_active({ direction = 1 }) then
            return cmp.snippet_forward()
          end

          -- 4. 否则，交还给 fallback（比如插入 <Tab> 字符）
          return false -- 等价于触发 'fallback'
        end,
        "fallback", -- 安全兜底（虽然函数已处理，但保留更健壮）
      },

      -- 可选：Shift+Tab 处理上一个
      ["<S-Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_prev()
          end
          if cmp.snippet_active({ direction = -1 }) then
            return cmp.snippet_backward()
          end
          return false
        end,
        "fallback",
      },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Esc>"] = { "hide", "fallback" },
      ["<C-d>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      -- 手动触发 LLM 代码补全（只看 LLM 建议）
      ["<C-y>"] = {
        function(cmp)
          cmp.show({ providers = { "llm" } })
        end,
        "fallback",
      },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = {
      trigger = {
        prefetch_on_insert = false, -- LLM 补全不预取（按需请求，省 token）
        show_on_blocked_trigger_characters = {}, -- 允许空格等字符触发（llm 前端触发字符：@ . ( [ : { 空格 /）
      },
      list = {
        selection = {
          preselect = false,
        },
      },
      menu = {
        auto_show = true,
        scrollbar = false,
        border = "rounded",
        winhighlight = "Normal:BlinkCmpMenu,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",

        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                local icon = ctx.kind_icon
                if ctx.source_name == "LLM" then
                  -- LLM 补全：固定机器人图标（无标准 kind）
                  icon = ""
                elseif vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local ok, dev_icon = pcall(function()
                    return require("mini.icons").get("file", ctx.label)
                  end)
                  if ok and dev_icon then
                    icon = dev_icon
                  end
                else
                  icon = require("lspkind").symbol_map[ctx.kind] or ""
                end

                return icon .. ctx.icon_gap
              end,

              -- Optionally, use the highlight groups from nvim-web-devicons
              -- You can also add the same function for `kind.highlight` if you want to
              -- keep the highlight groups in sync with the icons.
              highlight = function(ctx)
                local hl = ctx.kind_hl
                if ctx.source_name == "LLM" then
                  -- LLM 补全专属高亮（Dracula 紫）
                  hl = "BlinkCmpKindLLM"
                elseif vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local ok, _, dev_hl = pcall(function()
                    -- mini.icons.get 返回两个值：图标、高亮组
                    return require("mini.icons").get("file", ctx.label)
                  end)
                  if ok and dev_hl then
                    hl = dev_hl
                  end
                end
                return hl
              end,
            },

            kind = {
              -- 第 1 列的 kind 文字：LLM 项显示为 "LLM"（其余保持 LSP 标准 kind）
              text = function(ctx)
                if ctx.source_name == "LLM" then
                  return "LLM"
                end
                return ctx.kind
              end,
              -- LLM 项 kind 文字用专属紫
              highlight = function(ctx)
                if ctx.source_name == "LLM" then
                  return "BlinkCmpKindLLM"
                end
                return ctx.kind_hl
              end,
            },

            label = {
              -- 生成的代码文字保持默认（白色），不加 LLM 紫色
            },

            source_name = {
              text = function(ctx)
                return "[" .. ctx.source_name .. "]"
              end,
              highlight = "Comment",
              width = { fill = true },
            },
          },
          columns = {
            { "kind_icon", "kind", gap = 1 },
            { "label", "label_description", gap = 1 },
            { "source_name" },
          },
        },
      },
      documentation = {
        auto_show = false,
        window = {
          border = "rounded",
          scrollbar = false,
          winhighlight = "Normal:BlinkCmpDoc,FloatBorder:FloatBorder,EndOfBuffer:BlinkCmpDoc",
        },
      },
    },

    signature = {
      enabled = true,
      window = {
        border = "rounded",
        scrollbar = false,
      },
    },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },

      per_filetype = {
        -- 对话窗口（llm filetype）：只用 llm 相关 source，lsp/path 等不混入
        llm = { inherit_defaults = false },
      },

      providers = {
        -- LLM 代码补全（llm.nvim）：改为 <C-y> 手动触发
        llm = {
          name = "LLM",
          module = "llm.common.completion.frontends.blink",
          timeout_ms = 10000, -- 单次请求超时（毫秒）
          score_offset = 100, -- 排序权重（提高 LLM 建议的排名）
          async = true,
        },
      },
    },

    cmdline = {
      sources = function()
        local cmd_type = vim.fn.getcmdtype()
        if cmd_type == "/" then
          return { "buffer" }
        end
        if cmd_type == ":" then
          return { "cmdline" }
        end
        return {}
      end,
      keymap = {
        preset = "super-tab",
      },
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
  config = function(_, opts)
    require("blink.cmp").setup(opts)
    -- LLM 补全专属 kind 高亮（Dracula 紫）
    -- colorscheme 重载会清空自定义高亮，用 autocmd 兜底重设
    local function set_llm_hl()
      vim.api.nvim_set_hl(0, "BlinkCmpKindLLM", { fg = "#bd93f9", default = true })
    end
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_llm_hl })
    set_llm_hl()
  end,
}
