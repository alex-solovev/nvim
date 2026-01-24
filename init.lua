-- Fix for https://github.com/neovim/neovim/issues/31675
vim.hl = vim.highlight
require("config.lazy")

-- Basic formatting and line numbers
vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable paste from clipboard
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)
-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false
-- Enable Nerd font
vim.g.have_nerd_font = true
-- Save undo history
vim.opt.undofile = true
-- Case insensitive search
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Decrease update time
vim.opt.updatetime = 250
-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300
-- Show which line your cursor is on
vim.opt.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Show hover documentation with rounded border
vim.keymap.set("n", "<S-k>", function()
  vim.lsp.buf.hover({ border = "rounded" })
end, { desc = "" })

-- Highlight on copy
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Toggle inline diagnostics
vim.keymap.set("n", "<leader>td", function()
  local config = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = not config })
end, { desc = "Toggle diagnostics" })
