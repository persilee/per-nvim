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
  local start_text = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
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

-- ===== Callout 正文按类型着色 =====
-- render-markdown 只给 callout 标题/图标上色，正文统一是 @markup.quote 青色。
-- 这里用 treesitter 解析 block_quote + shortcut_link，把正文行按 callout 类型着色。
local callout_hl = {
  -- Info 系（绿）
  note = "RenderMarkdownInfo",
  info = "RenderMarkdownInfo",
  abstract = "RenderMarkdownInfo",
  summary = "RenderMarkdownInfo",
  tldr = "RenderMarkdownInfo",
  todo = "RenderMarkdownInfo",
  example = "RenderMarkdownInfo",
  question = "RenderMarkdownInfo",
  help = "RenderMarkdownInfo",
  -- Success 系（紫）
  tip = "RenderMarkdownSuccess",
  done = "RenderMarkdownSuccess",
  success = "RenderMarkdownSuccess",
  check = "RenderMarkdownSuccess",
  -- Error 系（红）
  failure = "RenderMarkdownError",
  fail = "RenderMarkdownError",
  missing = "RenderMarkdownError",
  danger = "RenderMarkdownError",
  error = "RenderMarkdownError",
  bug = "RenderMarkdownError",
  caution = "RenderMarkdownError",
  -- Warn 系（橙）
  attention = "RenderMarkdownWarn",
  warning = "RenderMarkdownWarn",
  -- Hint 系（青紫）
  important = "RenderMarkdownHint",
  wip = "RenderMarkdownHint",
  -- Quote 系（灰）
  quote = "RenderMarkdownQuote",
  cite = "RenderMarkdownQuote",
}

local CALL_BODY_NS = vim.api.nvim_create_namespace("CalloutBodyHL")

-- ===== 正文浅色组：标题色与白色混合，主次分明 =====
-- 每种 callout 的正文用一个独立高亮组 CalloutBody<Key>，颜色比标题浅 35%
local BODY_LIGHTEN = 0.36

local function lighten(hex, ratio)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)
  local mix = function(c)
    return math.floor(c + (255 - c) * ratio)
  end
  return string.format("#%02x%02x%02x", mix(r), mix(g), mix(b))
end

-- 懒生成正文组：从标题组（RenderMarkdownInfo 等）取色 → 混合白色
local body_group_name = {} -- callout key -> CalloutBody<Key>

-- 跟随 link 链解析最终 fg（RenderMarkdownInfo → DiagnosticInfo → #RRGGBB）
local function resolve_fg(name)
  local seen = {}
  while name and not seen[name] do
    seen[name] = true
    local h = vim.api.nvim_get_hl(0, { name = name })
    if h.fg then
      return h.fg
    end
    name = h.link
  end
  return nil
end

local function ensure_body_groups()
  for key, src in pairs(callout_hl) do
    if not body_group_name[key] then
      local fg = resolve_fg(src)
      if fg then
        local name = "CalloutBody" .. key:sub(1, 1):upper() .. key:sub(2)
        vim.api.nvim_set_hl(0, name, {
          fg = lighten(string.format("#%06x", fg), BODY_LIGHTEN),
          default = true,
        })
        body_group_name[key] = name
      else
        body_group_name[key] = src -- 取不到色就退回标题组
      end
    end
  end
end

local function color_callout_body(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  ensure_body_groups()
  vim.api.nvim_buf_clear_namespace(buf, CALL_BODY_NS, 0, -1)

  local ok_md, parser_md = pcall(vim.treesitter.get_parser, buf, "markdown")
  local ok_in, parser_in = pcall(vim.treesitter.get_parser, buf, "markdown_inline")
  if not ok_md or not parser_md or not ok_in or not parser_in then
    return
  end

  -- 1. 收集 block_quote 行范围（markdown parser）
  local ok_root, root_md = pcall(function()
    local tree = parser_md:parse()
    return tree and tree[1] and tree[1]:root() or nil
  end)
  if not ok_root or not root_md then
    return
  end
  local bq_ranges = {}
  local ok_q, q_md = pcall(vim.treesitter.query.parse, "markdown", "(block_quote) @bq")
  if not ok_q then
    return
  end
  for _, node, _, _ in q_md:iter_captures(root_md, buf) do
    if node and node.range then
      local srow, _, erow = node:range()
      table.insert(bq_ranges, { srow, erow })
    end
  end
  if #bq_ranges == 0 then
    return
  end

  -- 2. 收集 shortcut_link 所在行 → callout 类型（markdown_inline parser）
  local hl_by_row = {}
  local ok_root2, root_in = pcall(function()
    local tree = parser_in:parse()
    return tree and tree[1] and tree[1]:root() or nil
  end)
  if not ok_root2 or not root_in then
    return
  end
  local ok_q2, q_in = pcall(vim.treesitter.query.parse, "markdown_inline", "(shortcut_link) @cl")
  if not ok_q2 then
    return
  end
  for _, node, _, _ in q_in:iter_captures(root_in, buf) do
    if node and node.range then
      local srow = select(1, node:range())
      local text = vim.treesitter.get_node_text(node, buf)
      local key = text:lower():gsub("[%[%]!]", "")
      local hl = body_group_name[key] -- 正文浅色组
      if hl then
        hl_by_row[srow] = hl
      end
    end
  end

  -- 3. 对每个 block_quote：非标题行应用对应高亮
  for _, rng in ipairs(bq_ranges) do
    local hl = nil
    for row = rng[1], rng[2] do
      if hl_by_row[row] then
        hl = hl_by_row[row]
      end
    end
    if hl then
      local lines = vim.api.nvim_buf_get_lines(buf, rng[1], rng[2] + 1, false)
      for row = rng[1], rng[2] do
        -- 跳过标题行和空行
        if not hl_by_row[row] and lines[row - rng[1] + 1] and lines[row - rng[1] + 1]:match("%S") then
          vim.api.nvim_buf_set_extmark(buf, CALL_BODY_NS, row, 0, {
            end_row = row + 1,
            end_col = 0,
            hl_group = hl,
          })
        end
      end
    end
  end
end

-- 打开/进入 markdown buffer 时着色
vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
  buffer = 0,
  callback = function(args)
    local buf = args.buf
    -- 等 render-markdown 渲染完成后执行
    vim.schedule(function()
      pcall(color_callout_body, buf)
    end)
  end,
  desc = "callout 正文按类型着色",
})

-- 编辑时刷新（150ms 防抖）
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  buffer = 0,
  callback = function(args)
    local buf = args.buf
    vim.fn.timer_start(150, function()
      pcall(color_callout_body, buf)
    end)
  end,
  desc = "callout 正文着色刷新",
})
