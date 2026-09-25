-- markdown 文件专属配置
-- 软换行 + conceallevel（render-markdown 需要）
vim.opt_local.wrap = true
vim.opt_local.conceallevel = 2

-- ===== gx：在 render-markdown 渲染后仍能打开 [文本](url) 链接 =====
-- 渲染后方括号被 conceal，内置 gx 找不到 URL；这里直接读原始行内容解析
vim.keymap.set("n", "gx", function()
  local line = vim.fn.getline(".")
  local cursor_col = vim.fn.col(".")
  local pos = 1
  while pos <= #line do
    local open_bracket = line:find("%[", pos)
    if not open_bracket then
      break
    end
    local close_bracket = line:find("%]", open_bracket + 1)
    if not close_bracket then
      break
    end
    local open_paren = line:find("%(", close_bracket + 1)
    if not open_paren then
      break
    end
    local close_paren = line:find("%)", open_paren + 1)
    if not close_paren then
      break
    end
    if
      (cursor_col >= open_bracket and cursor_col <= close_bracket)
      or (cursor_col >= open_paren and cursor_col <= close_paren)
    then
      local url = line:sub(open_paren + 1, close_paren - 1)
      vim.ui.open(url)
      return
    end
    pos = close_paren + 1
  end
  -- 没匹配到 md 链接，回退内置 gx
  vim.cmd("normal! gx")
end, { buffer = true, desc = "打开 markdown 链接" })

-- ===== 折叠时显示标题原文 + render-markdown 的高亮色 =====
local function pad_to_eol(str)
  local win_width = vim.api.nvim_win_get_width(0)
  local str_width = vim.fn.strdisplaywidth(str)
  local spaces = win_width - str_width
  if spaces > 0 then
    return str .. string.rep(" ", spaces)
  end
  return str
end

local function fold_virt_text(result, start_text, lnum)
  -- 优先取 render-markdown 在该行设置的高亮组
  local hl_group
  local ns = vim.api.nvim_get_namespaces()["render-markdown.nvim"]
  if ns then
    local marks = vim.api.nvim_buf_get_extmarks(0, ns, { lnum, 0 }, { lnum, 0 }, { details = true })
    local last = marks[#marks]
    if last and last[4] then
      hl_group = last[4].hl_group
    end
  end
  -- 回退到 treesitter 捕获的高亮
  if not hl_group then
    local captures = vim.treesitter.get_captures_at_pos(0, lnum, 0)
    if #captures > 0 then
      local ts_hl = "@" .. captures[#captures].capture .. ".markdown"
      hl_group = vim.api.nvim_get_hl(0, { name = ts_hl, link = true }).link or ts_hl
    end
  end
  table.insert(result, { pad_to_eol(start_text), hl_group or "Normal" })
end

function _G.markdown_foldtext()
  local start_text = vim.fn
    .getline(vim.v.foldstart)
    :gsub("\t", string.rep(" ", vim.o.tabstop))
  local result = {}
  fold_virt_text(result, start_text, vim.v.foldstart - 1)
  return result
end

vim.opt_local.foldtext = "v:lua.markdown_foldtext()"

-- ===== zM：折叠到大纲视图（只展开 H1，折叠 H2~H6）=====
local function fold_headings_of_level(level)
  vim.cmd("keepjumps normal! gg")
  local total = vim.fn.line("$")
  for line = 1, total do
    local content = vim.fn.getline(line)
    if content:match("^" .. string.rep("#", level) .. "%s") then
      vim.cmd(string.format("keepjumps call cursor(%d, 1)", line))
      if vim.fn.foldlevel(line) > 0 and vim.fn.foldclosed(line) == -1 then
        vim.cmd("normal! za")
      end
    end
  end
end

vim.keymap.set("n", "zM", function()
  vim.cmd("silent update")
  vim.cmd("edit!") -- 重载文件刷新折叠
  vim.cmd("normal! zR") -- 先全部展开
  for _, level in ipairs({ 6, 5, 4, 3, 2 }) do
    fold_headings_of_level(level)
  end
  vim.cmd("normal! zz")
end, { buffer = true, desc = "折叠 md 大纲（H2 及以下）" })
