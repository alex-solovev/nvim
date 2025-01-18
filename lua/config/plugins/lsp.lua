return {
  {
    'neovim/nvim-lspconfig',

    dependencies = {
      -- Mason must be configured before LSP plugin
      { "williamboman/mason.nvim", opts = {} },
      "williamboman/mason-lspconfig.nvim",
      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },

    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local lspconfig = require('lspconfig')

      local servers = {
        ts_ls = {
          settings = {
            typescript = {
              suggest = {
                completeFunctionCalls = true
              }
            }
          }
        },

        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace"
              }
            }
          }
        },

        gopls = {
          settings = {
            gopls = {
              usePlaceholders = true,
              completeUnimported = true,
              experimentalPostfixCompletions = true,
            }
          }
        }
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          client.capabilities = capabilities

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

      require('mason-lspconfig').setup({
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      })
    end
  }
}
