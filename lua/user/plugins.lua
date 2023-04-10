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
  use({ "neovim/nvim-lspconfig", commit = "51775b1" })
  use({ "kdheepak/lazygit.nvim", commit = "9c73fd6" })
  use({ "AndrewRadev/switch.vim", commit = "900c5d3" })
  use({ "nvim-lua/plenary.nvim", commit = "968a4b9" })
  use({ "lewis6991/gitsigns.nvim", commit = "d7e0bcb" })
  use({ "shaunsingh/nord.nvim", commit = "209e9b3" })
  use({ "kyazdani42/nvim-web-devicons", commit = "2d02a56" })
  use({ "tamago324/lir.nvim", commit = "937e882" })
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
  use({ "hrsh7th/cmp-calc", commit = "50792f3" })
  use({ "f3fora/cmp-spell", commit = "60584cb" })
  use({ "dmitmel/cmp-cmdline-history", commit = "003573b" })
  use({ "ray-x/cmp-treesitter", commit = "b40178b" })
  use({ "doxnit/cmp-luasnip-choice", commit = "97a3678" })
  use({ "amarakon/nvim-cmp-buffer-lines", commit = "2036e6f" })
  use({ "rcarriga/cmp-dap", commit = "d16f14a" })
  use({ "jose-elias-alvarez/null-ls.nvim", requires = { "nvim-lua/plenary.nvim" }, commit = "4342844" })
  use({ "AckslD/nvim-trevJ.lua", commit = "7363619" })
  use({ "nicwest/vim-camelsnek", commit = "3fef4df" })
  use({ "axelvc/template-string.nvim", commit = "84e50b8" })
  use({ "nvim-treesitter/nvim-treesitter-textobjects", commit = "e63c2ff" })
  use({ "mizlan/iswap.nvim", commit = "a21edee" })
  use({ "winston0410/range-highlight.nvim", requires = { "winston0410/cmd-parser.nvim" }, commit = "8b5e8cc" })
  use({ "winston0410/cmd-parser.nvim", commit = "6363b8b" })
  use({ "ldelossa/buffertag", commit = "0322abc" })
  use({ "mclaughlinconnor/diffview.nvim", requires = "nvim-lua/plenary.nvim", rocks = { "diff" } })
  use({ "jose-elias-alvarez/typescript.nvim", commit = "b96b3f8" })
  -- Maybe use gv.vim and vim-fugitive for Vim
  use({ "lewis6991/impatient.nvim", commit = "9f7eed8" }) -- Maybe use gv.vim and vim-fugitive for Vim
  use({ "stevearc/dressing.nvim", commit = "4436d6f" })

  use({ "mxsdev/nvim-dap-vscode-js", requires = { "mfussenegger/nvim-dap" }, commit = "e7c0549" })
  use({
    "microsoft/vscode-js-debug",
    opt = true,
    run = "npm install --legacy-peer-deps && npm run compile",
    tag = "v1.*",
  })
  use({ "mfussenegger/nvim-dap", commit = "5a1479c", requires = { { "rcarriga/nvim-dap-ui", commit = "b80227e" } } })
  use({ "theHamsta/nvim-dap-virtual-text", commit = "1913459" })
  use({ "ton/vim-alternate", commit = "57a6d27" })

  use({ "lukas-reineke/indent-blankline.nvim", commit = "018bd04" })

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
