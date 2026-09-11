-- Fix for https://github.com/neovim/neovim/issues/31675
vim.hl = vim.highlight

vim.g.mapleader = " "

vim.opt.termguicolors = true
vim.opt.smoothscroll = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.signcolumn = "yes:1"
-- vim.opt.showmatch = true
vim.opt.cmdheight = 0
vim.opt.pumheight = 10
vim.opt.pumblend = 10
-- vim.opt.winblend = 10
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
vim.opt.lazyredraw = false
vim.opt.synmaxcol = 300
vim.opt.fillchars = { eob = " " }

vim.opt.undofile = true
vim.opt.showmode = false
vim.opt.confirm = true
vim.opt.winborder = "single"

vim.g.have_nerd_font = true

vim.opt.splitbelow = true
vim.opt.splitright = true

-- Folding (requires treesitter)
vim.opt.foldmethod = "manual"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

-- Undo dir config
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = undodir
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.redrawtime = 1000
vim.opt.maxmempattern = 20000
vim.opt.autoread = true -- audo reload files changed outside of nvim
vim.opt.autowrite = false
vim.opt.hidden = true -- allow hidden buffers
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.autochdir = false
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")
-- vim.opt.selection = "inclusive"
vim.opt.mouse = "a"
-- vim.opt.clipboard:append("unnamedplus")
vim.opt.modifiable = true
vim.opt.encoding = "utf-8"

-- Install Packages
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/oskarnurm/koda.nvim",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  {
    src = "https://github.com/nvim-telescope/telescope.nvim",
  },
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
  },
})

require("mason").setup()
require("oil").setup()
local blink = require("blink.cmp")

blink.setup({
  fuzzy = { implementation = "prefer_rust_with_warning" },
})

vim.cmd.colorscheme("koda")
-- vim.cmd("syntax off")

vim.lsp.config("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        version = "LuaJIT",
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
    })
  end,
  settings = {
    Lua = {},
  },
})

vim.lsp.enable("tsc")
vim.lsp.enable("css-lsp")
vim.lsp.enable("superhtml")
vim.lsp.enable("svelte")
vim.lsp.enable("oxfmt")
vim.lsp.enable("oxlint")
vim.lsp.enable("lua_ls")

vim.lsp.config("tsc", {
  cmd = { "tsc", "--lsp", "--stdio" },
})

vim.lsp.config["*"] = {
  capabilities = blink.get_lsp_capabilities(),
}

-- Formatting setup
require("conform").setup({
  formatters_by_ft = {
    css = { "prettier" },
    html = { "superhtml" },
    lua = { "stylua" },
    -- TODO use vp fmt command instead
    javascript = { "prettier", stop_after_first = true },
    typescript = { "prettier", stop_after_first = true },
    svelte = { "prettier", stop_after_first = true },
  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

-- Enable paste from clipboard
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Show hover documentation
vim.keymap.set("n", "<S-k>", vim.lsp.buf.hover, { desc = "" })

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight on copy
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  desc = "Highlight when yanking (copying) text",
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  desc = "Restore last cursor position",
  callback = function()
    if vim.o.diff then
      return
    end

    local last_pos = vim.api.nvim_buf_get_mark(0, '"')
    local last_line = vim.api.nvim_buf_line_count(0)

    local row = last_pos[1]
    if row < 1 or row > last_line then
      return
    end

    pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
  end,
})

-- Toggle inline diagnostics
vim.keymap.set("n", "<leader>td", function()
  local config = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = not config })
end, { desc = "Toggle diagnostics" })

-- Treesitter setup
local setup_treesitter = function()
  local treesitter = require("nvim-treesitter")
  treesitter.setup({})
  local ensure_installed = {
    "vim",
    "vimdoc",
    "rust",
    "c",
    "cpp",
    "go",
    "html",
    "css",
    "javascript",
    "json",
    "lua",
    "markdown",
    "python",
    "typescript",
    "vue",
    "svelte",
    "bash",
  }

  local config = require("nvim-treesitter.config")

  local already_installed = config.get_installed()
  local parsers_to_install = {}

  for _, parser in ipairs(ensure_installed) do
    if not vim.tbl_contains(already_installed, parser) then
      table.insert(parsers_to_install, parser)
    end
  end

  if #parsers_to_install > 0 then
    treesitter.install(parsers_to_install)
  end

  local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
      if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
        vim.treesitter.start(args.buf)
      end
    end,
  })
end

setup_treesitter()

local diagnostic_signs = {
  Error = " ",
  Warn = " ",
  Hint = "",
  Info = "",
}

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
      [vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
      [vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
      [vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "single",
    source = true,
    header = "",
    prefix = "",
    focusable = false,
    style = "minimal",
  },
})

do
  local orig = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "single"
    return orig(contents, syntax, opts, ...)
  end
end

local function lst_on_attach(event)
  local client = vim.lsp.get_client_by_id(event.data.client_id)

  if not client then
    return
  end

  local bufnr = event.buf
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "<leader>ld", function()
    vim.diagnostic.open_float({ scope = "line" })
  end, opts)

  if client:supports_method("textDocument/codeAction", bufnr) then
    vim.keymap.set("n", "<leader>oi", function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" }, diagnostics = {} },
        apply = true,
        bufnr = bufnr,
      })

      vim.defer_fn(function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end, 50)
    end, opts)
  end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lst_on_attach })

-- Telescope config
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")
vim.keymap.set("n", "<leader><leader>", function()
  builtin.git_files(themes.get_ivy({}))
end, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>ss", function()
  builtin.live_grep(themes.get_ivy({}))
end, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>oo", function()
  builtin.buffers(themes.get_ivy({}))
end, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", function()
  builtin.help_tags(themes.get_ivy({}))
end, { desc = "Telescope help tags" })

-- Keymaps
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set("n", "<C-j>", ":cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "<C-k>", ":cprev<CR>", { desc = "Prev quickfix item" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Open Oil
vim.keymap.set("n", "-", ":Oil<CR>", { desc = "Open Oil" })

require("pins").setup()
require("lualine").setup({
  options = {
    theme = "onelight",
    component_separators = "",
    section_separators = "",
  },
})
