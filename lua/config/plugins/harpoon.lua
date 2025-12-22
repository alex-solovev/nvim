return {
  "ThePrimeagen/harpoon",
  config = function()
    local set = vim.keymap.set

    set("n", "<C-a>", require("harpoon.mark").add_file, { desc = "Add File to Harpoon" })
    set("n", "<C-h>", require("harpoon.ui").toggle_quick_menu, { desc = "Toggle Harpoon" })

    set("n", "<C-1>", function()
      require("harpoon.ui").nav_file(1)
    end, { desc = "Harpoon File 1" })
    set("n", "<C-2>", function()
      require("harpoon.ui").nav_file(2)
    end, { desc = "Harpoon File 2" })
    set("n", "<C-3>", function()
      require("harpoon.ui").nav_file(3)
    end, { desc = "Harpoon File 3" })
    set("n", "<C-4>", function()
      require("harpoon.ui").nav_file(4)
    end, { desc = "Harpoon File 4" })
  end,
}
