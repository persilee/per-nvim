-- plugins/llm.lua —— llm.nvim：Neovim 内对话式 LLM 插件（DeepSeek 配置）
-- 依赖：curl（系统）、fzf >= 0.37（可选，会话历史预览）
-- 环境变量：LLM_KEY（必填，DeepSeek API Key）
return {
  "Kurama622/llm.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- 通用 Lua 工具库
    "MunifTanjim/nui.nvim", -- nvim UI 组件库（聊天窗口渲染）
  },
  cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
  -- ============ 命令层快捷键 ============
  keys = {
    -- 对话
    { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>", desc = "打开/关闭 LLM 对话" },

    -- AI 工具（LLMAppHandler 工具名）
    { "<leader>ae", mode = "v", "<cmd>LLMAppHandler CodeExplain<cr>", desc = "LLM 解释选中代码" },
    { "<leader>aw", mode = "n", "<cmd>LLMAppHandler WordTranslate<cr>", desc = "LLM 翻译光标下单词" },
    { "<leader>aw", mode = "v", "<cmd>LLMAppHandler WordTranslate<cr>", desc = "LLM 翻译选中文本" },
    {
      "<leader>aa",
      mode = "n",
      "<cmd>LLMAppHandler Ask<cr>",
      desc = "LLM 随机提问（当前缓冲区为上下文）",
    },
    { "<leader>aa", mode = "v", "<cmd>LLMAppHandler Ask<cr>", desc = "LLM 就选中代码提问" },
    { "<leader>aA", mode = "v", "<cmd>LLMAppHandler AttachToChat<cr>", desc = "LLM 附加上下文提问" },
    { "<leader>ao", mode = "v", "<cmd>LLMAppHandler OptimizeCode<cr>", desc = "LLM 优化选中代码" },
    { "<leader>ag", mode = "n", "<cmd>LLMAppHandler CommitMsg<cr>", desc = "LLM 生成 git commit 信息" },
    { "<leader>ad", mode = { "n", "v" }, "<cmd>LLMAppHandler DocString<cr>", desc = "LLM 生成 docstring" },
  },
  config = function()
    require("llm").setup({
      -- ============ DeepSeek API 核心配置 ============
      url = "https://api.deepseek.com/chat/completions", -- DeepSeek 官方 API 端点
      model = "deepseek-chat", -- 模型：deepseek-chat(V3) / deepseek-reasoner(R1)
      api_type = "deepseek", -- 后端类型：与 lua/llm/backends/deepseek.lua 对应

      -- ============ 模型参数 ============
      max_tokens = 4096, -- 单次回复最大 token 数
      temperature = 0.3, -- 采样温度（0~2，越低越稳定/保守）
      top_p = 0.7, -- 核采样（与 temperature 二选一调节随机性）
      enable_thinking = false, -- 是否启用思考模式（deepseek-reasoner 专用）

      -- ============ 对话行为 ============
      prompt = "You are a helpful chinese assistant.", -- 系统提示词（模型角色设定）
      spinner = {
        text = {
          "󰧞󰧞",
          "󰧞󰧞",
          "󰧞󰧞",
          "󰧞󰧞",
        },
        hl = "Title",
      },
      prefix = { -- 消息角色前缀（图标 + 高亮组）
        user = { text = "😃 ", hl = "Title" },
        assistant = { text = "  ", hl = "Added" },
      },
      save_session = true, -- 保存会话历史（重启 nvim 后可恢复）
      max_history = 15, -- 历史会话列表条数上限
      max_history_name_length = 20, -- 历史会话名称最大长度

      -- ============ AI 工具（通过 LLMAppHandler 调用，官方要求放在 app_handler 字段） ============
      app_handler = {
        -- ① 快速翻译：Normal 模式翻译光标下单词，Visual 模式翻译选中文本
        WordTranslate = {
          handler = "flexi_handler", -- 弹性窗口显示结果（窗口大小随输出量自适应）
          prompt = [[You are a translation expert. Your task is to translate all the text provided by the user into Chinese.

NOTE:
- All the text input by the user is part of the content to be translated, and you should ONLY FOCUS ON TRANSLATING THE TEXT without performing any other tasks.
- RETURN ONLY THE TRANSLATED RESULT.]],
          opts = {
            exit_on_move = true, -- 光标移动即关闭结果窗口
            enter_flexible_window = false, -- 不自动进入结果窗口
            enable_cword_context = true, -- 启用光标下单词上下文（Normal 模式直接翻译光标词）
          },
        },

        -- ② 解释代码：Visual 模式选中代码，用中文解释
        CodeExplain = {
          handler = "flexi_handler",
          prompt = "Explain the following code, please only return the explanation, and answer in Chinese",
          opts = {
            enter_flexible_window = true, -- 自动进入结果窗口（方便查看/复制）
          },
        },

        -- ③ 随机提问：灵活提问（可选中代码提问，也可 Normal 模式以当前缓冲区为上下文直接问）
        Ask = {
          handler = "disposable_ask_handler",
          opts = {
            position = { -- 提问输入窗口位置
              row = 2,
              col = 0,
            },
            title = " Ask ", -- 输入窗口标题
            inline_assistant = true, -- 行内助手模式
            enable_buffer_context = true, -- Normal 模式调用时以当前缓冲区为上下文
            language = "Chinese", -- 回答语言
            diagnostic = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN }, -- 附带诊断信息

            -- 模型配置（改用 DeepSeek，与主配置一致；官方示例默认 chatanywhere 免费 API）
            url = "https://api.deepseek.com/chat/completions",
            model = "deepseek-chat",
            api_type = "deepseek",
            fetch_key = vim.env.LLM_KEY, -- 读取环境变量 LLM_KEY（与主配置共用）

            -- diff 操作键位（inline_assistant 的改动预览）
            display = { -- 显示 diff
              mapping = { mode = "n", keys = { "d" } },
              action = nil,
            },
            accept = { -- 接受 diff
              mapping = { mode = "n", keys = { "Y", "y" } },
              action = nil,
            },
            reject = { -- 拒绝 diff
              mapping = { mode = "n", keys = { "N", "n" } },
              action = nil,
            },
            close = { -- 关闭 diff
              mapping = { mode = "n", keys = { "<esc>" } },
              action = nil,
            },
          },
        },

        -- ④ 附加上下文提问：选中内容作为上下文附加到对话
        AttachToChat = {
          handler = "attach_to_chat_handler",
          opts = {
            is_codeblock = true, -- 选中的代码包在代码块中
            inline_assistant = true, -- 行内助手模式
            diagnostic = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
            language = "Chinese",
            display = { mapping = { mode = "n", keys = { "d" } }, action = nil }, -- d 显示 diff
            accept = { mapping = { mode = "n", keys = { "Y", "y" } }, action = nil }, -- Y/y 接受
            reject = { mapping = { mode = "n", keys = { "N", "n" } }, action = nil }, -- N/n 拒绝
            close = { mapping = { mode = "n", keys = { "<esc>" } }, action = nil }, -- Esc 关闭
          },
        },

        -- ⑤ 优化代码：左右窗口对比原代码与优化结果
        OptimizeCode = {
          handler = "side_by_side_handler", -- 左右分栏显示
          opts = {
            left = { -- 左侧（原代码）窗口
              focusable = false, -- 不可聚焦（默认操作右侧结果）
            },
            diagnostic = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR }, -- 附带诊断
          },
        },

        -- ⑥ 生成 git commit 信息：按 Conventional Commits 规范生成提交信息
        CommitMsg = {
          handler = "flexi_handler",
          prompt = function()
            -- 基于 git diff（暂存区）生成提交信息
            return string.format(
              [[You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:

1. First line: conventional commit format (type: concise description) (remember to use semantic types like feat, fix, docs, style, refactor, perf, test, chore, etc.)
2. Optional bullet points if more context helps:
   - Keep the second line blank
   - Keep them short and direct
   - Focus on what changed
   - Always be terse
   - Don't overly explain
   - Drop any fluffy or formal language

Return ONLY the commit message - no introduction, no explanation, no quotes around it.

Examples:
feat: add user auth system

- Add JWT tokens for API auth
- Handle token refresh for long sessions

fix: resolve memory leak in worker pool

- Clean up idle connections
- Add timeout for stale workers

Simple change example:
fix: typo in README.md

Very important: Do not respond with any of the examples. Your message must be based off the diff that is about to be provided, with a little bit of styling informed by the recent commits you're about to see.And the final generated commit message shall be in Chinese.

Based on this format, generate appropriate commit messages. Respond with message only. DO NOT format the message in Markdown code blocks, DO NOT use backticks:

```diff
%s
```
]],
              vim.fn.system("git diff --no-ext-diff --staged") -- 取暂存区 diff
            )
          end,
          opts = {
            enter_flexible_window = true, -- 自动进入结果窗口
            apply_visual_selection = false, -- 不使用选中文本（仅用 git diff）
            win_opts = { -- 结果窗口位置
              relative = "editor",
              position = "50%",
            },
            accept = { -- 按回车确认提交
              mapping = { mode = "n", keys = "<cr>" },
              action = function()
                local contents = vim.api.nvim_buf_get_lines(0, 0, -1, true)
                local tmpname = os.tmpname()
                local f = io.open(tmpname, "w")
                assert(f, "Failed to open tmpfile!")
                for _, line in ipairs(contents) do
                  f:write(line, "\n")
                end
                f:close()
                local cmd = "!git commit -F " .. vim.fn.shellescape(tmpname)
                vim.api.nvim_command(cmd)
                os.remove(tmpname)
                vim.schedule(function()
                  vim.api.nvim_command("LazyGit") -- 提交后打开 lazygit 查看
                end)
              end,
            },
          },
        },

        -- ⑦ 生成 docstring：按语言规范生成文档注释，以 diff 形式展示在源码上
        DocString = {
          prompt = [[ You are an AI programming assistant. You need to write a really good docstring that follows a best practice for the given language.

Your core tasks include:
- parameter and return types (if applicable).
- any errors that might be raised or returned, depending on the language.

You must:
- Place the generated docstring before the start of the code.
- Follow the format of examples carefully if the examples are provided.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of the Markdown code blocks.]],
          handler = "action_handler", -- 在源文件上以 diff 形式展示
          opts = {
            only_display_diff = true, -- 只显示 diff（不直接写入）
            templates = { -- 语言专属模板
              lua = [[- For the Lua language, you should use the LDoc style.
- Start all comment lines with "---".
]],
            },
          },
        },
      },

      -- ============ 对话窗口内键位 ============
      keys = {
        -- 输入框
        ["Input:Submit"] = { mode = "n", key = "<cr>" }, -- 提交问题
        ["Input:Cancel"] = { mode = { "n", "i" }, key = "<C-c>" }, -- 取消
        ["Input:Resend"] = { mode = { "n", "i" }, key = "<C-r>" }, -- 重发上次提问
        -- 历史会话切换（需 save_session = true）
        ["Input:HistoryNext"] = { mode = { "n", "i" }, key = "<C-j>" }, -- 下一个历史会话
        ["Input:HistoryPrev"] = { mode = { "n", "i" }, key = "<C-k>" }, -- 上一个历史会话

        -- 输出窗口（split 布局）
        ["Output:Ask"] = { mode = "n", key = "i" }, -- 进入提问
        ["Output:Cancel"] = { mode = "n", key = "<C-c>" }, -- 取消生成
        ["Output:Resend"] = { mode = "n", key = "<C-r>" }, -- 重发

        -- 窗口开关（float 布局）
        ["Session:Toggle"] = { mode = "n", key = "<leader>ac" }, -- 开关对话窗口
        ["Session:Close"] = { mode = "n", key = { "<esc>", "Q" } }, -- 关闭窗口

        -- 滚动
        ["PageUp"] = { mode = { "i", "n" }, key = "<C-b>" }, -- 向上翻页
        ["PageDown"] = { mode = { "i", "n" }, key = "<C-f>" }, -- 向下翻页
        ["HalfPageUp"] = { mode = { "i", "n" }, key = "<C-u>" }, -- 向上半页
        ["HalfPageDown"] = { mode = { "i", "n" }, key = "<C-d>" }, -- 向下半页
        ["JumpToTop"] = { mode = "n", key = "gg" }, -- 跳转顶部
        ["JumpToBottom"] = { mode = "n", key = "G" }, -- 跳转底部
      },
    })
  end,
}
