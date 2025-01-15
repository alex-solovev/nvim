return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    config = function()
      require('telescope').setup({
        pickers = {
          find_files = { theme = 'ivy' },
          git_files = { theme = 'ivy' }
        },
        extensions = {
          fzf = {}
        }
      })

      require('telescope').load_extension('fzf')

      local builtin = require('telescope.builtin')

      local set = vim.keymap.set

      local function edit_nvim_config()
        builtin.find_files({ cwd = vim.fn.stdpath('config') })
      end

      set('n', '<space>fh', builtin.help_tags, { desc = 'Show help tags' })
      set('n', '<space>ff', builtin.find_files, { desc = 'Find project files' })
      set('n', '<space>fg', builtin.git_files, { desc = 'Find GIT files' })
      set('n', '<space>en', edit_nvim_config, { desc = 'Edit NeoVim config' })
    end
  }
}
