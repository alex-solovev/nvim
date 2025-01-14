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

vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.relativenumber = true

print("Ready to rock!")
