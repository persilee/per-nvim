-- vim-tmux-navigator：vim 与 tmux pane 之间无缝导航
-- C-h/j/k/l 在 vim 内移动；到 vim 窗口边缘时自动切换到相邻 tmux pane
-- 需配合 tmux 侧配置（tmux.conf 中 run-shell 加载 vim-tmux-navigator.tmux）
return {
  { "christoomey/vim-tmux-navigator", lazy = false },
}
