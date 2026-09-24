# Neovim 配置功能与快捷键总结

> 配置目录：`~/.config/nvim` · 包管理器：lazy.nvim · 生成时间：2026-09-24

---

## 一、配置总览

这是一套基于 **lazy.nvim** 构建的独立定制配置（未启用 LazyVim 官方插件集，`LazyVim/LazyVim` 的 import 已在 `lazy.lua` 中注释），从零组合了文件管理、LSP、补全、界面美化等 20+ 个插件，整体风格为**透明背景 + Dracula/Gradient Dracula 配色**。

### 目录结构

```
~/.config/nvim
├── init.lua                    # 入口：加载 options / keymaps / autocmds / lazy
├── lazy-lock.json              # 插件版本锁定
├── lazyvim.json                # LazyVim 遗留配置（editor.ufo 折叠增强）
├── .neoconf.json               # neodev / neoconf 配置（Lua 开发）
├── stylua.toml                 # Lua 格式化配置
└── lua/
    ├── config/
    │   ├── options.lua         # 基础选项
    │   ├── keymaps.lua         # 自定义快捷键
    │   ├── autocmds.lua        # 自动命令（透明化、高亮等）
    │   └── lazy.lua            # lazy.nvim 启动配置
    ├── plugins/                # 各插件配置（按插件拆分）
    ├── colors/color1.lua       # 自定义调色板
    └── customs/float_trem.lua  # 浮窗终端模块（预留）
```

---

## 二、基础编辑选项（options.lua）

| 选项 | 值 | 说明 |
|---|---|---|
| `number` / `relativenumber` | on | 显示行号 + 相对行号 |
| `expandtab` / `shiftwidth` / `tabstop` | 2 | Tab 转为空格，缩进宽度 2 |
| `smartindent` | on | 智能缩进 |
| `termguicolors` | on | 真彩色 |
| `swapfile` | off | 关闭交换文件 |
| `mouse` | a | 全模式启用鼠标 |
| `laststatus` | 3 | 全局状态栏 |
| `clipboard` | unnamedplus | 与系统剪贴板同步 |
| `autoread` | on | 文件外部变更自动重读 |
| `ignorecase` / `smartcase` | on | 搜索忽略大小写（含大写时区分） |
| `hlsearch` | off | 搜索后不高亮残留 |
| `foldmethod` | expr | Treesitter 表达式折叠 |
| `foldlevelstart` | 99 | 打开文件默认全部展开，不折叠 |
| `wrap` | off | 全局关闭长行自动折行 |
| `formatoptions` | 去掉 c/r/o | 禁止自动注释续行 |
| `cursorline` / `cursorlineopt` | on / number | 只高亮光标所在行号（粉色加粗） |
| `guicursor` | 自定义 | 普通=方块、插入=25%竖线、替换=20%横线、操作符=半高方块 |
| `modeline` | off | 禁用模型行 |
| `iskeyword` | 追加 `-` | 让 `-` 参与单词跳转 |
| `whichwrap` | 追加 `<>h,l` | 左右键可跨行移动 |
| `winborder` | rounded | 窗口圆角边框 |
| `diagnostic.signs` | off | 左侧 gutter 不显示 E/W 图标 |

**自定义命令**：`:Hv [主题词]` —— 在新垂直分屏中打开 help。

---

## 三、插件功能清单

### 1. 补全与代码智能

| 插件 | 功能要点 |
|---|---|
| **blink.cmp** | 现代化补全引擎。来源：LSP / 路径 / 代码片段 / 缓冲区；Snippet 支持（LuaSnip + friendly-snippets）；`<C-d>` 文档、`<C-k>` 签名；模糊匹配用 Rust 实现（`prefer_rust_with_warning`）；命令行补全（`/` 走 buffer、`:` 走 cmdline） |
| **nvim-lspconfig** | 内置 9 个 LSP：`clangd`（C/C++）、`cmake`、`pyright`（自动探测 `.venv/venv/env` 虚拟环境）、`lua_ls`（识别 `vim`/`hs` 全局，加载 config 与 lazy 库）、`bashls`、`html`、`cssls`、`tsserver`（JS/TS）、`tex`（texlab）、`jsonls`（内置 package.json/tsconfig/.eslintrc 的 JSON Schema） |
| **lspsaga** | LSP 增强 UI：圆角边框、winbar 符号导航（breadcrumb） |
| **trouble.nvim** | 诊断/引用/符号列表窗口，底部 30% 高度 |
| **fidget.nvim** | LSP 进度提示 |
| **mason.nvim** | LSP / 格式化工具安装器 |

### 2. 文件管理与导航

| 插件 | 功能要点 |
|---|---|
| **oil.nvim** | 以"普通缓冲区"方式浏览文件系统（`nvim .` 直接打开，替代 netrw）。特性：图标列、winbar 显示当前路径、隐藏文件切换（`zh`）、详情列切换（`gd`） |
| **neo-tree.nvim** | 已配置但 `enabled = false` **禁用**（被 oil 替代） |
| **aerial.nvim** | 代码大纲侧边栏（LSP + Treesitter 双后端），缩进引导线，`<leader>o` 切换 |
| **hop.nvim** | 字符级精准跳转（详见快捷键） |
| **nvim-spectre** | 全局搜索替换面板，基于 ripgrep（`rg`），支持高亮预览 |

### 3. 编辑增强

| 插件 | 功能要点 |
|---|---|
| **nvim-autopairs** | 自动补全括号/引号，Treesitter 感知，同行避免重复括号 |
| **nvim-surround** | 环绕符号操作：`ysiw"` 加引号、`ds"` 删除、`cs"'` 替换 |
| **Comment.nvim** | 一键注释：`gcc` 行注释、`gbc` 块注释、`gc`/`gb` 操作符 |
| **vim-visual-multi** | 多光标编辑（详见快捷键） |
| **smear-cursor.nvim** | 光标移动丝滑动画（阻尼/帧率调优，兼容 0.11 命令模式抖动） |
| **neoscroll.nvim** | `<C-u>`/`<C-d>` 平滑滚动（quadratic 缓动） |
| **conform.nvim** | 保存时自动格式化：Lua(stylua) / Python(black) / JS·TS·HTML·CSS·JSONC(prettier) / JSON(jq) / Shell(shfmt) / C·C++(clang-format) / TeX(tex-fmt)，500ms 超时 |
| **nvim-treesitter** | 语法高亮、缩进、增量选择、折叠；已装 c/cpp/lua/python/cmake |
| **nvim-treesitter-textobjects** | 基于语法树的对象选择 |
| **nvim-colorizer.lua** | 颜色值（#hex 等）实时着色显示 |

### 4. Git 集成

| 插件 | 功能要点 |
|---|---|
| **gitsigns.nvim** | 行内 Git 增删改标记 |
| **lazygit.nvim** | 在 Neovim 内打开 LazyGit 界面，`<leader>gg` |

### 5. 界面与美化

| 插件 | 功能要点 |
|---|---|
| **theme.lua** | 当前激活：**Gradient Dracula**（nvimpire 引擎，透明背景）。预置可选主题：tokyonight / dracula / nvimpire / kanagawa / catppuccin / gruvbox / nightfox / fluoromachine / oxocarbon / rose-pine / onedark / vscode / github / onedarkpro / melange / monokai-pro（改 `active_theme` 变量即可切换） |
| **heirline.nvim** | 自定义状态栏：模式指示器（彩色文字）、Git 分支、文件图标+名+修改点、保存 ✓ 提示（2 秒）、Git diff 计数、诊断计数、弹性工作目录（自动缩短）、LSP 服务名、光标行列 |
| **bufferline.nvim** | 标签页栏：序号显示、过滤空 buffer、自定义关闭逻辑（最后一个 buffer 用 `enew`）、图标、LSP 诊断点、完全透明 |
| **noice.nvim** | 命令行/消息 UI 美化：命令行浮窗、消息走 notify、错误弹窗、外部命令输出弹窗、搜索历史 |
| **nvim-notify** | 通知中心（Noice 后端，背景 #1e1e2e） |
| **snacks.nvim** | 全家桶：缩进引导线 + 当前作用域高亮、**Picker 查找器**（替代 Telescope）、底部/浮动终端、Dashboard 启动页、输入增强 |
| **mini.icons** | 文件/文件类型图标，并 mock 了 `nvim-web-devicons` 接口（其他插件自动兼容） |
| **lualine.nvim** | 已配置但 `enabled = false` **禁用**（被 heirline 替代） |

### 6. 自动行为（autocmds.lua）

- **透明化**：ColorScheme 时批量将 Normal / BufferLine / StatusLine / Pmenu 等 30+ 高亮组设为透明背景
- **光标配色**：普通模式粉色方块、插入模式绿色竖线、替换模式紫色横线
- **搜索高亮**：`CurSearch` 薄荷绿底
- **补全菜单**：Pmenu 透明、选中项粉色加粗、边框冰白色
- **启动隐藏标签栏**：`showtabline = 0`（配合 bufferline 自身显示）
- **C/C++ 文件**：自动切换为 syntax 折叠
- **保存自动建目录**：`BufWritePre` 自动 `mkdir -p` 不存在的父目录

---

## 四、自定义快捷键总表（leader = 空格）

### 1. 文件操作

| 快捷键 | 功能 |
|---|---|
| `<leader>w` / `<leader>q` / `<leader>Q` | 保存 / 退出 / 保存并退出 |
| `<C-S-A-w>` | 保存当前文件 |
| `<C-S-A-s>` | 保存全部文件（wall） |
| `<C-S-A-q>` / `<C-S-A-x>` | 退出 / 保存并退出 |
| `<C-S-A-a>` | 全选（普通/可视/插入模式均可用） |

### 2. 窗口与分屏

| 快捷键 | 功能 |
|---|---|
| `<leader>h` / `<leader>j` / `<leader>k` / `<leader>l` | 切换到 左/下/上/右 窗口 |
| `<leader><Left>` / `<Down>` / `<Up>` / `<Right>` | 同上（方向键版） |
| `<A-Up>` / `<A-Down>` | 增加 / 减少窗口高度（±2） |
| `<A-Left>` / `<A-Right>` | 减少 / 增加窗口宽度（±2） |

### 3. 缓冲区 / 标签页

| 快捷键 | 功能 |
|---|---|
| `<leader><PageDown>` / `<leader><PageUp>` | 下一个 / 上一个 Tab |
| `<leader>1` ~ `<leader>9` | 跳转到第 1~9 号缓冲区 |
| `<leader>c` | 关闭当前缓冲区（Snacks.bufdelete，有未保存修改会提示） |
| `<leader>tb` | 显示 / 隐藏标签页栏 |

### 4. 行操作与缩进

| 快捷键 | 功能 |
|---|---|
| `<A-j>` / `<A-k>` | 下移 / 上移当前行（可视模式为移动选中块） |
| `<Tab>` / `<S-Tab>`（可视） | 选中块整体 缩进 / 反缩进 |

### 5. 搜索与文本选择

| 快捷键 | 功能 |
|---|---|
| `<C-f>` | 搜索光标下的单词（`*`） |
| `<Esc>` | 清除搜索高亮 |
| `vv` | 选中到匹配的括号（v%） |
| `vc` | 选中当前单词（viw） |
| `vl` | 进入行选择模式（V） |
| `dw` | 删除当前单词（diw） |

### 6. 复制粘贴

| 快捷键 | 功能 |
|---|---|
| `<C-c>` | 复制（普通=整行 `"+yy`，可视=选中 `"+y`）到系统剪贴板 |
| `<C-v>` / `p` | 从系统剪贴板粘贴到光标位置（普通/可视） |
| `p`（可视模式） | 粘贴时不覆盖无名寄存器 |

### 7. 文件浏览器（Oil）

| 快捷键 | 功能 |
|---|---|
| `<leader>e` / `-` | 打开 / 关闭 Oil 文件浏览器 |
| `-` / `<leader>e` | 关闭 Oil 窗口 |
| `<BS>` | 返回上一级父目录 |
| `\` / `\|` | 水平 / 垂直分屏打开选中文件 |
| `<C-r>` | 刷新当前目录 |
| `<leader>y` | 复制条目名到寄存器 |
| `zh` | 切换隐藏文件显示 |
| `gd` | 切换文件详情列（权限/大小/时间） |
| `gr` / `gc` / `g/` | 跳到项目根 / cwd / 系统根目录 |
| `q` | 关闭 Oil |

### 8. 代码导航与 LSP

| 快捷键 | 功能 |
|---|---|
| `<leader>o` | 切换 Aerial 代码大纲 |
| `<leader>xx` | Trouble 诊断列表 |
| `gd` / `gD` | 跳转定义 / 声明 |
| `gr` | 查找引用 |
| `gI` / `gy` | 跳转实现 / 类型定义 |
| `gai` / `gao` | 调用者 / 被调用者 |
| `<leader>ss` / `<leader>sS` | 当前文件 / 工作区 LSP 符号 |

### 9. Snacks Picker（查找器）

| 快捷键 | 功能 |
|---|---|
| `<leader><space>` | 智能查找 |
| `<leader>ff` / `<leader>fg` | 查找文件 / Grep 全文 |
| `<leader>fp` / `<leader>fr` | 最近项目 / 最近文件 |
| `<leader>fb` | 缓冲区列表 |
| `<leader>fh` / `<leader>fk` | 查找帮助 / 查找快捷键 |
| `<leader>fl` / `<leader>:` / `<leader>/` | Picker 布局 / 命令历史 / 搜索历史 |
| `<leader>sd` | 诊断列表 |
| `<leader>gs` / `<leader>gd` | Git 状态 / Git Diff |

### 10. 终端

| 快捷键 | 功能 |
|---|---|
| `<leader>tt` | 切换底部终端（zsh，自动进入插入模式） |
| `<leader>tf` | 打开浮动终端（80%×80%） |
| `<leader>tl` / `<leader>tn` | 列出终端会话 / 新建会话 |
| `<Esc>`（终端内） | 退出到普通模式 |
| `q`（终端内） | 隐藏终端 |
| `<C-l>`（终端内） | 清屏 |

### 11. 多光标（vim-visual-multi）

| 快捷键 | 功能 |
|---|---|
| `<leader>mn` / `<leader>mp` | 选中下一个 / 上一个匹配项 |
| `<leader>ma` | 全选所有匹配项 |
| `<leader>ms` / `<leader>mr` | 跳过 / 移除当前光标 |
| `<leader>mq` | 退出多光标模式 |
| `<M-S-j>` / `<M-S-k>` | 向下 / 向上逐行添加光标（列编辑） |
| `<leader>mt` | 切换扩展 / 光标模式 |

### 12. 字符跳转（Hop）

| 快捷键 | 功能 |
|---|---|
| `<leader>js` | 双字符精准跳转 |
| `<leader>jf` | 单字符全局跳转（跨行） |
| `<leader>jF` | 当前行内反向单字符跳转 |
| `<leader>jl` / `<leader>jw` / `<leader>jp` | 跳转到行 / 单词 / 正则匹配 |

### 13. 其它

| 快捷键 | 功能 |
|---|---|
| `<leader>gg` | 打开 LazyGit |
| `<leader>sr` / `<leader>sw` / `<leader>sf` | Spectre 全局搜索替换 / 搜索当前词 / 文件内搜索 |
| `<leader>nh` / `<leader>nl` / `<leader>ne` | Noice 通知历史 / 最近一条 / 错误历史 |
| `<leader>nd` / `<leader>np` | 清除通知 / 搜索历史消息 |
| `<leader>cc` | 光标一键切换为粉色方块 |

---

## 五、Neovim 常用内置快捷键补充

> 以下为 Neovim / Vim 通用操作，配置未覆盖但日常高频使用。

### 1. 模式切换与光标移动

| 快捷键 | 功能 |
|---|---|
| `i` / `a` / `o` | 光标前插入 / 光标后插入 / 新行插入 |
| `I` / `A` / `O` | 行首插入 / 行尾插入 / 上方新行插入 |
| `v` / `V` / `<C-v>` | 字符可视 / 行可视 / 块可视 |
| `h` `j` `k` `l` | 左 下 上 右 移动 |
| `w` / `b` / `e` | 下一个单词词首 / 上一个单词词首 / 单词词尾 |
| `W` / `B` / `E` | 同上（按空白分隔的大词） |
| `0` / `^` / `$` | 行首（含缩进） / 行首（第一个字符） / 行尾 |
| `gg` / `G` / `nG` | 文件开头 / 文件末尾 / 跳到第 n 行 |
| `{` / `}` | 上一个 / 下一个空行（段落） |
| `%` | 跳到匹配的括号 |
| `H` / `M` / `L` | 跳到屏幕 顶 / 中 / 底 |
| `<C-f>` / `<C-b>` | 向下翻页 / 向上翻页 |
| `<C-d>` / `<C-u>` | 向下滚半屏 / 向上滚半屏 |
| `zz` / `zt` / `zb` | 当前行居中 / 置顶 / 置底 |

### 2. 编辑操作

| 快捷键 | 功能 |
|---|---|
| `x` / `X` | 删除光标字符 / 删除光标前字符 |
| `dd` / `cc` / `yy` | 删除行 / 改写行 / 复制行 |
| `D` / `C` / `Y` | 删除到行尾 / 改写到行尾 / 复制到行尾 |
| `diw` / `daw` | 删除单词内部 / 删除整个单词（含空格） |
| `ciw` / `caw` | 改写单词内部 / 改写整个单词 |
| `dtx` / `dfx` | 删除到字符 x 前 / 删除到字符 x（含） |
| `u` / `<C-r>` | 撤销 / 重做 |
| `.` | 重复上次修改 |
| `J` | 合并下一行 |
| `>>` / `<<` | 当前行缩进 / 反缩进 |
| `r` / `R` | 替换单个字符 / 进入替换模式 |
| `~` | 切换大小写 |
| `s` / `S` | 删除字符进入插入 / 删除整行进入插入 |

### 3. 复制粘贴与寄存器

| 快捷键 | 功能 |
|---|---|
| `"+y` / `"+p` | 复制到系统剪贴板 / 从系统剪贴板粘贴 |
| `"ay` / `"ap` | 复制到寄存器 a / 从寄存器 a 粘贴 |
| `:reg` | 查看所有寄存器 |
| `yiw` / `yaw` | 复制单词内部 / 复制整个单词 |

### 4. 搜索与替换

| 快捷键 | 功能 |
|---|---|
| `/` `?` | 向下 / 向上搜索 |
| `*` / `#` | 搜索光标下单词 向下 / 向上 |
| `n` / `N` | 下一个 / 上一个匹配 |
| `:%s/旧/新/g` | 全局替换（加 `c` 逐个确认） |
| `:%s/旧/新/gc` | 带确认的全局替换 |
| `:noh` | 取消搜索高亮 |

### 5. 多窗口操作

| 快捷键 | 功能 |
|---|---|
| `:sp` / `:vsp` | 水平 / 垂直分屏 |
| `<C-w>s` / `<C-w>v` | 水平 / 垂直分屏（命令版） |
| `<C-w>h` / `j` / `k` / `l` | 窗口间移动 |
| `<C-w>w` | 循环切换窗口 |
| `<C-w>=` | 等分窗口 |
| `<C-w>_` / `<C-w>\|` | 最大化窗口高度 / 宽度 |
| `<C-w>o` | 只保留当前窗口 |
| `<C-w>c` / `<C-w>q` | 关闭当前窗口 |

### 6. 缓冲区与标签

| 快捷键 | 功能 |
|---|---|
| `:e 文件` / `:tabe 文件` | 打开文件 / 新标签打开 |
| `:bn` / `:bp` / `:b#` | 下一个 / 上一个 / 上一个切换的缓冲区 |
| `:bd` | 删除缓冲区 |
| `:ls` | 列出所有缓冲区 |
| `gt` / `gT` | 下一个 / 上一个标签页 |
| `:tabnew` / `:tabclose` | 新建 / 关闭标签页 |

### 7. 折叠

| 快捷键 | 功能 |
|---|---|
| `zc` / `zo` | 关闭 / 打开当前折叠 |
| `zM` / `zR` | 全部折叠 / 全部展开 |
| `za` | 切换折叠 |
| `zj` / `zk` | 跳到下一个 / 上一个折叠 |

### 8. 其它常用

| 快捷键 | 功能 |
|---|---|
| `:w` / `:q` / `:wq` / `:q!` | 保存 / 退出 / 保存退出 / 强制退出 |
| `:x` | 等同 `:wq` |
| `<C-o>` / `<C-i>` | 跳转历史 后退 / 前进 |
| `Ctrl+]` / `Ctrl+t` | 标签跳转 进入 / 返回 |
| `m` + 小写字母 | 设置标记 |
| `'` + 标记字母 | 跳转到标记 |
| `:!命令` | 执行外部命令 |
| `:terminal` | 打开内置终端 |
| `:Lazy` | 打开 lazy.nvim 插件管理界面 |
| `:Mason` | 打开 Mason 安装器 |
| `:TSInstall 语言` | 安装 Treesitter 解析器 |
| `:LspInfo` | 查看当前 LSP 状态 |
| `:checkhealth` | 健康检查 |
| `:messages` | 查看历史消息 |

---

## 六、主题快速切换

在 `lua/plugins/theme.lua` 顶部修改 `active_theme` 变量即可换肤，可用值：

| 变量值 | 主题 |
|---|---|
| `gradient_dracula`（当前） | Gradient Dracula（Dracula 渐变风，透明） |
| `tokyonight` / `dracula` / `nvimpire` | TokyoNight Night / Dracula Soft / Nvimpire |
| `kanagawa` / `catppuccin` / `gruvbox` | Kanagawa Wave / Catppuccin Mocha / Gruvbox Medium |
| `nightfox` / `fluoromachine` / `oxocarbon` | Dawnfox / 荧光机 / Oxocarbon |
| `rose_pine` / `onedark` / `onedarkpro` | Rose Pine / OneDark / Vaporwave |
| `vscode` / `github` / `melange` / `monokai` | VSCode / GitHub Dark / Melange / Monokai Pro |

---

## 七、小贴士

1. **补全菜单**：`<Tab>` 选中下一项（不自动插入），`<CR>` 确认，`<C-d>` 查看文档，`<C-k>` 查看签名。
2. **状态栏 `✓ Saved`**：保存成功后绿色提示 2 秒自动消失。
3. **自动格式化**：保存时自动执行，若不想格式化某文件可用 `:ConformInfo` 查看并临时禁用。
4. **C/C++**：折叠使用 syntax 模式，Python/Lua 等使用 Treesitter 折叠（默认全部展开）。
5. **Git 仓库**：状态栏会显示分支与增删改计数，行号旁有 gitsigns 标记。
6. **浮窗终端模块**（`lua/customs/float_trem.lua`）已预留但当前未绑定快捷键，实际终端功能由 Snacks 提供。
