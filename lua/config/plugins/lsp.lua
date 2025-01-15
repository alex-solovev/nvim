return {
  {
    'neovim/nvim-lspconfig',

    dependencies = {
      {
        'folke/lazydev.nvim',
        ft = 'lua', -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          },
        },
      },
      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },

    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup()

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local lspconfig = require('lspconfig')

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace"
            }
          }
        }
      })

      lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = {
          gopls = {
            usePlaceholders = true,
            completeUnimported = true,
            experimentalPostfixCompletions = true,
          }
        }
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          if client.supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
              end
            })
          end
        end,
      })

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
    end
  }
}
