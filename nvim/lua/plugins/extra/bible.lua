return {
  {
    "anthony-halim/bible-verse.nvim",
    cmd = "BibleVerse",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      diatheke = {
        translation = "KJV",
      },
    },
    config = true,
    keys = {
      { "<leader>Bq", "<cmd>BibleVerse query<cr>",  desc = "Bible query" },
      { "<leader>Bi", "<cmd>BibleVerse insert<cr>", desc = "Bible insert" },
    },
    enabled = not os.getenv("NVIM_DISABLE_BIBLE_VERSE"),
  },
}
