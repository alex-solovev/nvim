return {
  {
    "stevearc/oil.nvim",
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if prefer nvim-web-devicons
    config = function()
      require("oil").setup({
        columns = {
          "icon",
          -- 'permissions',
          "size",
          -- 'mtime',
        },
      })

      vim.keymap.set("n", "-", function()
        require("oil").open()
      end, { desc = "Open parent directory" })
    end,
  },
}
