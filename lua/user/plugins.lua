local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

-- Install your plugins here
return packer.startup(function(use)
  use({ "numToStr/Comment.nvim", commit = "30d23aa" })
  use({ "arkav/lualine-lsp-progress", commit = "56842d0" })
  use({ "mclaughlinconnor/vimtex", commit = "cff605f4" })
  use({ "mbbill/undotree", commit = "bf76bf2" })
  use({ "saadparwaiz1/cmp_luasnip", commit = "a9de941" })
  use({ "williamboman/mason.nvim", commit = "134c4d9" })
  use({ "norcalli/nvim-colorizer.lua", commit = "36c610a" })
  use({
    "nvim-telescope/telescope-fzf-native.nvim",
    commit = "65c0ee3",
    run = [[
      cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release \
        && cmake --build build --config Release \
        && cmake --install build --prefix build
    ]],
  })
  use({ "L3MON4D3/LuaSnip", run = "make install_jsregexp", commit = "6e506ce" })
  use({ "wbthomason/packer.nvim", commit = "00ec5ad" })
  use({ "windwp/nvim-autopairs", commit = "5fe2441" })
  use({ "ludovicchabant/vim-gutentags", commit = "b77b8fa" })
  use({ "neovim/nvim-lspconfig", commit = "f8b3c24" })
  use({ "kdheepak/lazygit.nvim", commit = "9c73fd6" })
  use({ "AndrewRadev/switch.vim", commit = "900c5d3" })
  use({ "nvim-lua/plenary.nvim", commit = "968a4b9" })
  use({ "lewis6991/gitsigns.nvim", commit = "d7e0bcb" })
  use({ "shaunsingh/nord.nvim", commit = "209e9b3" })
  use({ "kyazdani42/nvim-web-devicons", commit = "2d02a56" })
  use({ "kyazdani42/nvim-tree.lua", requires = { "kyazdani42/nvim-web-devicons" }, commit = "fb8735e" })
  use({ "hrsh7th/cmp-nvim-lsp", commit = "affe808" })
  use({ "hrsh7th/nvim-cmp", commit = "913eb85" })
  use({ "nvim-treesitter/playground", commit = "bcfab84" })
  use({ "hrsh7th/cmp-cmdline", commit = "9c0e331" })
  use({ "machakann/vim-sandwich", commit = "74898e6" })
  use({ "nvim-treesitter/nvim-treesitter", commit = "2eaf188" })
  use({ "nvim-telescope/telescope.nvim", commit = "2584ff3" })
  use({ "nvim-lua/lsp-status.nvim", commit = "54f48eb" })
  use({ "williamboman/mason-lspconfig.nvim", commit = "1534b61" })
  use({ "nvim-lualine/lualine.nvim", commit = "a52f078", requires = { "kyazdani42/nvim-web-devicons", opt = true } })
  use({ "p00f/nvim-ts-rainbow", commit = "620a24f" })
  use({ "hrsh7th/cmp-path", commit = "447c87c" })
  use({ "hrsh7th/cmp-buffer", commit = "3022dbc" })
  use({ "jose-elias-alvarez/null-ls.nvim", requires = { "nvim-lua/plenary.nvim" }, commit = "4342844" })
  use({ "AckslD/nvim-trevJ.lua", commit = "7363619" })
  use({ "nicwest/vim-camelsnek", commit = "3fef4df" })
  -- Maybe use gv.vim and vim-fugitive for Vim

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
