require("config.lazy")

require("oil").setup({
  columns = {
    "icon",
    "permissions",
    -- "size",
    -- "mtime",
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

print("Ready to rock!")
