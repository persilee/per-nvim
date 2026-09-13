return {
  "nvim-mini/mini.icons",
  lazy = false, -- 启动即加载，确保mock在其他插件之前生效
  opts = {
    style = "glyph", -- glyph=字形图标，ascii=纯字符回退
  },
  file = {
    README = { glyph = "󰆈", hl = "MiniIconsYellow" },
    ["README.md"] = { glyph = "󰆈", hl = "MiniIconsYellow" },
  },
  filetype = {
    bash = { glyph = "󱆃", hl = "MiniIconsGreen" },
    sh = { glyph = "󱆃", hl = "MiniIconsGrey" },
    toml = { glyph = "󱄽", hl = "MiniIconsOrange" },
  },
  config = function(_, opts)
    local mini_icons = require("mini.icons")
    mini_icons.setup(opts)

    -- 🔴 关键：模拟 nvim-web-devicons 全局接口
    -- 所有依赖 web-devicons 的插件都会自动使用 mini.icons
    mini_icons.mock_nvim_web_devicons()

    -- 把上面查到的高亮组替换成对应名称，颜色值改成你想要的蓝色
    vim.api.nvim_set_hl(0, "MiniIconsAzure", { fg = "#61afef" })
  end,
}
