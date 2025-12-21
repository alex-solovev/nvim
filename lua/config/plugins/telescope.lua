return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' ==
              1
        end
      },
      { 'nvim-telescope/telescope-ui-select.nvim' }
    },
    config = function()
      require('telescope').setup({
        pickers = {
          find_files = { theme = 'ivy' },
          git_files = { theme = 'ivy' }
        },
        extensions = {
          fzf = {},
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          }
        }
      })

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require('telescope.builtin')
      local set = vim.keymap.set

      local function edit_nvim_config()
        builtin.find_files({ cwd = vim.fn.stdpath('config') })
      end

      set('n', '<space>fh', builtin.help_tags, { desc = 'Show help tags' })
      set('n', '<space>ff', builtin.find_files, { desc = 'Find project files' })
      set('n', '<space>fg', builtin.git_files, { desc = 'Find GIT files' })
      set('n', '<space>en', edit_nvim_config, { desc = 'Edit NeoVim config' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })
    end
  }
}
