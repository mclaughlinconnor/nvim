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
  use({ "nvim-lua/plenary.nvim", commit = "267282a" })

  -- Editor
  use({ "NvChad/nvim-colorizer.lua", commit = "dde3084" })
  use({ "numToStr/Comment.nvim", commit = "176e85e" })
  use({ "windwp/nvim-autopairs", commit = "e8f7dd7" })
  use({ "AndrewRadev/switch.vim", commit = "a3fd7bf" })
  use({ "machakann/vim-sandwich", commit = "c5a2cc4" })
  -- https://github.com/Wansmer/treesj seems more powerfull
  use({ "AckslD/nvim-trevJ.lua", commit = "7f40154" })
  use({ "axelvc/template-string.nvim", commit = "e347d83" })
  use({ "mizlan/iswap.nvim", commit = "8213a12" })
  use({
    "winston0410/range-highlight.nvim",
    requires = { { "winston0410/cmd-parser.nvim", commit = "6363b8b" } },
    commit = "8b5e8cc",
  })
  use({ "mbbill/undotree", commit = "485f01e" })
  use({ "tamago324/lir.nvim", commit = "959ac31" })
  use({ "ton/vim-alternate", commit = "57a6d27" })

  -- Code
  use({ "ludovicchabant/vim-gutentags", commit = "1337b18" })
  use({ "arkav/lualine-lsp-progress", commit = "56842d0" })
  use({ "nvim-lua/lsp-status.nvim", commit = "54f48eb" })
  use({ "neovim/nvim-lspconfig", commit = "9a2cc56" })
  use({ "mclaughlinconnor/vimtex", commit = "cff605f4" })
  use({
    "pmizio/typescript-tools.nvim",
    commit = "1b0af27",
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  })

  use({ "jose-elias-alvarez/null-ls.nvim", requires = { "nvim-lua/plenary.nvim" }, commit = "bbaf5a9" })

  -- Debugging/testing
  use({
    "nvim-neotest/neotest",
    requires = {
      { "mclaughlinconnor/neotest-mocha", commit = "deefd41" },
      { "jbyuki/one-small-step-for-vimkind", commit = "f239ca0" },
    },
    commit = "e46eae5",
  })
  use({ "folke/neodev.nvim", commit = "b41da39" })
  use({ "mxsdev/nvim-dap-vscode-js", requires = { "mfussenegger/nvim-dap" }, commit = "03bd296" })
  use({
    "microsoft/vscode-js-debug",
    commit = "8fa24a7",
    opt = true,
    run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
  })
  use({ "mfussenegger/nvim-dap", commit = "a6d48d2", requires = { { "rcarriga/nvim-dap-ui", commit = "c020f66" } } })
  use({ "theHamsta/nvim-dap-virtual-text", commit = "57f1dbd" })

  -- Completion
  use({ "L3MON4D3/LuaSnip", run = "make install_jsregexp", commit = "4964cd1" })
  use({ "amarakon/nvim-cmp-buffer-lines", commit = "2036e6f" })
  use({ "dmitmel/cmp-cmdline-history", commit = "003573b" })
  use({ "doxnit/cmp-luasnip-choice", commit = "97a3678" })
  use({ "f3fora/cmp-spell", commit = "60584cb" })
  use({ "hrsh7th/cmp-buffer", commit = "3022dbc" })
  use({ "hrsh7th/cmp-calc", commit = "50792f3" })
  use({ "hrsh7th/cmp-cmdline", commit = "8ee981b" })
  use({ "hrsh7th/cmp-nvim-lsp", commit = "0e6b2ed" })
  use({ "hrsh7th/cmp-omni", commit = "9436e6c" })
  use({ "hrsh7th/cmp-path", commit = "91ff86c" })
  use({ "hrsh7th/nvim-cmp", commit = "b8c2a62" })
  use({ "ray-x/cmp-treesitter", commit = "389eadd" })
  use({ "rcarriga/cmp-dap", commit = "d16f14a" })
  use({ "saadparwaiz1/cmp_luasnip", commit = "1809552" })

  -- Plugin management
  use({ "williamboman/mason.nvim", commit = "f7f81ab" })
  use({ "wbthomason/packer.nvim", commit = "1d0cf98" })
  use({ "williamboman/mason-lspconfig.nvim", commit = "d381fcb" })

  -- Git
  use({ "kdheepak/lazygit.nvim", commit = "3466e48" })
  use({ "lewis6991/gitsigns.nvim", commit = "256569c" })
  use({
    "sindrets/diffview.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    commit = "766a4f2",
  })

  -- Theming
  use({ "shaunsingh/nord.nvim", commit = "fab04b2" })
  use({
    "nvim-lualine/lualine.nvim",
    commit = "05d78e9",
    requires = { "kyazdani42/nvim-web-devicons", opt = true, commit = "14b3a5b" },
  })

  -- Enable only in pug files
  use({ "lukas-reineke/indent-blankline.nvim", commit = "7075d78" })
  use({ "folke/tokyonight.nvim", commit = "1825940" })
  use({ "ldelossa/buffertag", commit = "59df485" })

  -- Treesitter
  use({ "nvim-treesitter/playground", commit = "2b81a01" })
  use({ "nvim-treesitter/nvim-treesitter", commit = "fdddbff" })
  use({ "HiPhish/nvim-ts-rainbow2", commit = "0921443" })
  use({ "nvim-treesitter/nvim-treesitter-textobjects", commit = "2d6d3c7" })

  -- Telescope
  use({ "stevearc/dressing.nvim", commit = "5fb5cce" })
  use({
    "ibhagwan/fzf-lua",
    commit = "b587997",
  })

  -- Makes it go fast
  -- Not needed for 0.9: vim.loader.enable()
  use({ "lewis6991/impatient.nvim", commit = "9f7eed8" })

  -- Currently being tested
  use({ "TimUntersberger/neogit", commit = "e94b159", requires = "nvim-lua/plenary.nvim" })

  use({ "uga-rosa/utf8.nvim", commit = "954cbba" })

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
