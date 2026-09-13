vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
