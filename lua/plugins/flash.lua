return {
  "folke/flash.nvim",
  event = "VeryLazy",
  config = function(_, opts)
    require("flash").setup(opts)
    -- 覆盖为 flash 官方红色系配色
    vim.api.nvim_set_hl(0, "FlashMatch", { fg = "#282A36", bg = "#F8F8F2" }) -- 匹配字符：红底
    vim.api.nvim_set_hl(0, "FlashCurrent", { fg = "#1b1d2b", bg = "#ff966c" }) -- 当前候选：橙红底
    vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#c8d3f5", bg = "#ff007c", bold = true }) -- 跳转标签：品红底
    vim.api.nvim_set_hl(0, "FlashCursor", { reverse = true })
  end,
  opts = {
    modes = {
      search = {
        enabled = true,
      },
      char = {
        jump_labels = true,
      },
    },
  },
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },
    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Treesitter Search",
    },
    {
      "<c-s>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search",
    },
  },
}
