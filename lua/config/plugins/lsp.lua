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
        ts_ls                       = {
          settings = {
            typescript = {
              suggest = {
                completeFunctionCalls = true
              }
            }
          }
        },

        svelteserver                = {},

        tailwindcss_language_server = {},

        lua_ls                      = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace"
              }
            }
          }
        },

        gopls                       = {
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

          local function set(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = args.buf, desc = 'LSP: ' .. desc })
          end

          set("n", "gd", vim.lsp.buf.definition, "Go to definition")
          set("n", "grn", vim.lsp.buf.rename, "[R]e[n]ame")
          set("n", "gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction")
          set("n", "grr", require('telescope.builtin').lsp_references, "[G]oto [R]eferences")
          set("n", "gri", require('telescope.builtin').lsp_implementations, "[G]oto [I]mplementation")
          set("n", "grd", require('telescope.builtin').lsp_definitions, "[G]oto [D]efinition")
          set("n", "grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          set("n", "gO", require('telescope.builtin').lsp_document_symbols, "Open Document Symbols")
          set("n", "gW", require('telescope.builtin').lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
          set("n", "grt", require('telescope.builtin').lsp_type_definitions, "[G]oto [T]ype Definition")
        end,
      })


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
