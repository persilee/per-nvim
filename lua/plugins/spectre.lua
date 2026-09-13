return {
  "windwp/nvim-spectre",
  event = "VeryLazy",
  keys = {
    {
      "<leader>sr",
      function()
        require("spectre").open()
      end,
      desc = "全局搜索替换",
    },
    {
      "<leader>sw",
      function()
        require("spectre").open_visual({ select_word = true })
      end,
      desc = "搜索当前单词",
    },
    {
      "<leader>sf",
      function()
        require("spectre").open_file_search()
      end,
      desc = "当前文件内搜索替换",
    },
  },
  config = function()
    require("spectre").setup({
      default = {
        find = {
          cmd = "rg", -- 使用 ripgrep 引擎
          options = { "ignore-case" },
        },
      },
      highlight = {
        ui = "String",
        search = "DiffDelete",
        replace = "DiffAdd",
      },
    })
  end,
}
