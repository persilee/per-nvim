return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup({
      preset = "ghost",
      transparent_bg = true, -- 去掉诊断提示的背景色（默认 false 会显示 CursorLine 背景）
      options = {
        multilines = {
          enabled = true,
          always_show = true,
        },
        enable_on_select = true,

        virt_texts = {
          priority = 2048,
        },
      },
    })
    vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
  end,
}
