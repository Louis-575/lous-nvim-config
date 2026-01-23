------------------------------------------------------------
-- Neovim init.lua
------------------------------------------------------------

------------------------------------------------------------
-- Basic settings
------------------------------------------------------------
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.cmd("colorscheme habamax")


------------------------------------------------------------
-- Custom Keybinds 
------------------------------------------------------------
vim.keymap.set("n", " e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer", silent = true, })

vim.keymap.set("n", " t", "<cmd>Telescope<CR>", { desc = "Toggle telescope", silent = true, })

------------------------------------------------------------
-- Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({
  -- Dependency used by many plugins
  { "nvim-lua/plenary.nvim" },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { silent = true, desc = "Toggle file explorer" })
    end,
  },

  -- Lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({})
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
      vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { silent = true, desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { silent = true, desc = "Grep in project" })
      vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { silent = true, desc = "Buffers" })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.config")
      if not ok then
        vim.notify("Treesitter failed to load", vim.log.levels.ERROR)
        return
      end

      configs.setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = { "lua", "python", "vim", "vimdoc", "json", "bash" },
        auto_install = true,
      })
    end,
  },

  -- LSP configuration
  { "neovim/nvim-lspconfig" },

  -- Autocompletion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
})


------------------------------------------------------------
-- LSP 
------------------------------------------------------------

-- Capabilities (for nvim-cmp integration)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Configure pyright
vim.lsp.config.pyright = {
  capabilities = capabilities,
}

-- Enable pyright
vim.lsp.enable("pyright")

-- LSP keymaps when a server attaches
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  end,
})


------------------------------------------------------------
-- nvim-cmp
------------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
  }),
})

------------------------------------------------------------
