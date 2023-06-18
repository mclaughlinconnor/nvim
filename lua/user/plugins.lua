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
  use({ "nvim-lua/plenary.nvim", commit = "968a4b9" })

  -- Editor
  use({ "norcalli/nvim-colorizer.lua", commit = "36c610a" })
  use({ "numToStr/Comment.nvim", commit = "30d23aa" })
  use({ "windwp/nvim-autopairs", commit = "5fe2441" })
  use({ "AndrewRadev/switch.vim", commit = "900c5d3" })
  use({ "machakann/vim-sandwich", commit = "74898e6" })
  use({ "AckslD/nvim-trevJ.lua", commit = "7363619" })
  use({ "nicwest/vim-camelsnek", commit = "3fef4df" })
  use({ "axelvc/template-string.nvim", commit = "84e50b8" })
  use({ "mizlan/iswap.nvim", commit = "a21edee" })
  use({
    "winston0410/range-highlight.nvim",
    requires = { { "winston0410/cmd-parser.nvim", commit = "6363b8b" } },
    commit = "8b5e8cc",
  })
  use({ "mbbill/undotree", commit = "bf76bf2" })
  use({ "tamago324/lir.nvim", commit = "937e882" })
  use({ "ton/vim-alternate", commit = "57a6d27" })

  -- Code
  use({ "ludovicchabant/vim-gutentags", commit = "b77b8fa" })
  use({ "arkav/lualine-lsp-progress", commit = "56842d0" })
  use({ "nvim-lua/lsp-status.nvim", commit = "54f48eb" })
  use({ "neovim/nvim-lspconfig", commit = "427378a" })
  use({ "mclaughlinconnor/vimtex", commit = "cff605f4" })
  use({ "jose-elias-alvarez/typescript.nvim", commit = "b96b3f8" })
  use({ "jose-elias-alvarez/null-ls.nvim", requires = { "nvim-lua/plenary.nvim" }, commit = "4342844" })

  -- Debugging/testing
  use({
    "nvim-neotest/neotest",
    requires = {
      { "mclaughlinconnor/neotest-mocha",    commit = "deefd41" },
      { "jbyuki/one-small-step-for-vimkind", commit = "27e5f59" },
    },
    commit = "972a7dc",
  })
  use({ "folke/neodev.nvim", commit = "7e3f718" })
  use({ "mxsdev/nvim-dap-vscode-js", requires = { "mfussenegger/nvim-dap" }, commit = "03bd296" })
  use({
    "microsoft/vscode-js-debug",
    commit = "52b31fc",
    opt = true,
    run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
  })
  use({ "mfussenegger/nvim-dap", commit = "55e3a7f", requires = { { "rcarriga/nvim-dap-ui", commit = "286f682" } } })
  use({ "theHamsta/nvim-dap-virtual-text", commit = "ab988db" })

  -- Completion
  use({ "saadparwaiz1/cmp_luasnip", commit = "a9de941" })
  use({ "L3MON4D3/LuaSnip", run = "make install_jsregexp", commit = "6e506ce" })
  use({ "hrsh7th/cmp-nvim-lsp", commit = "affe808" })
  use({ "hrsh7th/nvim-cmp", commit = "913eb85" })
  use({ "hrsh7th/cmp-cmdline", commit = "9c0e331" })
  use({ "hrsh7th/cmp-path", commit = "447c87c" })
  use({ "hrsh7th/cmp-buffer", commit = "3022dbc" })
  use({ "hrsh7th/cmp-calc", commit = "50792f3" })
  use({ "f3fora/cmp-spell", commit = "60584cb" })
  use({ "dmitmel/cmp-cmdline-history", commit = "003573b" })
  use({ "ray-x/cmp-treesitter", commit = "b40178b" })
  use({ "doxnit/cmp-luasnip-choice", commit = "97a3678" })
  use({ "amarakon/nvim-cmp-buffer-lines", commit = "2036e6f" })
  use({ "rcarriga/cmp-dap", commit = "d16f14a" })
  use({ "hrsh7th/cmp-omni", commit = "8457e41" })

  -- Plugin management
  use({ "williamboman/mason.nvim", commit = "057ac5c" })
  use({ "wbthomason/packer.nvim", commit = "00ec5ad" })
  use({ "williamboman/mason-lspconfig.nvim", commit = "43f2ddf" })

  -- Git
  use({ "kdheepak/lazygit.nvim", commit = "9c73fd6" })
  use({ "lewis6991/gitsigns.nvim", commit = "d7e0bcb" })
  use({
    "mclaughlinconnor/diffview.nvim",
    requires = { { "nvim-lua/plenary.nvim", commit = "968a4b9" } },
    rocks = { "diff" },
  })

  -- Theming
  use({ "shaunsingh/nord.nvim", commit = "209e9b3" })
  use({
    "nvim-lualine/lualine.nvim",
    commit = "a52f078",
    requires = { "kyazdani42/nvim-web-devicons", opt = true, commit = "2d02a56" },
  })
  use({ "lukas-reineke/indent-blankline.nvim", commit = "018bd04" })
  use({ "folke/tokyonight.nvim", commit = "1b0c880" })
  use({ "ldelossa/buffertag", commit = "0322abc" })

  -- Treesitter
  use({ "nvim-treesitter/playground", commit = "bcfab84" })
  use({ "nvim-treesitter/nvim-treesitter", commit = "2eaf188" })
  use({ "p00f/nvim-ts-rainbow", commit = "620a24f" })
  use({ "nvim-treesitter/nvim-treesitter-textobjects", commit = "e63c2ff" })

  -- Telescope
  use({ "stevearc/dressing.nvim", commit = "4436d6f" })
  use({
    "ibhagwan/fzf-lua",
    commit = "b587997",
  })

  -- Makes it go fast
  use({ "lewis6991/impatient.nvim", commit = "9f7eed8" })

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
