return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      dir_path = "./attachments",
      use_absolute_path = false,
      copy_images = true,
      prompt_for_file_name = false,
      file_name = "%y%m%d-%H%M%S",
      extension = "avif",
      process_cmd = "magick convert - -quality 75 avif:-",
      formats = { "jpeg", "jpg", "png" },
    },
    filetypes = {
      markdown = {
        template = "![image$CURSOR]($FILE_PATH)",
      },
      tex = {
        dir_path = "./figs",
        extension = "png",
        process_cmd = "",
        template = [[
    \begin{figure}[h]
      \centering
      \includegraphics[width=0.8\textwidth]{$FILE_PATH}
    \end{figure}
        ]],
      },
      typst = {
        dir_path = "./figs",
        extension = "png",
        process_cmd = "magick convert - -density 300 png:-",
        formats = { "jpeg", "jpg", "png", "pdf", "svg" },
        template = [[
          #align(center)[#image("$FILE_PATH", height: 80%)]
          ]],
      },
    },
  },
  keys = {
    -- suggested keymap
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
