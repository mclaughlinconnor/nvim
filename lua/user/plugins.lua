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
  use({ "nvim-lua/plenary.nvim", commit = "55d9fe89e33efd26f532ef20223e5f9430c8b0c0" })

  -- Editor
  use({ "NvChad/nvim-colorizer.lua", commit = "dde3084106a70b9a79d48f426f6d6fec6fd203f7" })
  use({ "numToStr/Comment.nvim", commit = "0236521ea582747b58869cb72f70ccfa967d2e89" })
  use({ "windwp/nvim-autopairs", commit = "0f04d78619cce9a5af4f355968040f7d675854a1" })
  use({ "AndrewRadev/switch.vim", commit = "68d269301181835788dcdcb6d5bca337fb954395" })
  use({ "machakann/vim-sandwich", commit = "c5a2cc438ce6ea2005c556dc833732aa53cae21a" })
  -- https://github.com/Wansmer/treesj seems more powerfull
  use({ "AckslD/nvim-trevJ.lua", commit = "7f401543b5cd5496b6120dddcab394c29983a55c" })
  use({ "axelvc/template-string.nvim", commit = "5559125aba8499695eb23c3ff2434a13fb05e304" })
  use({ "mizlan/iswap.nvim", commit = "6b77e8a2235aebbc6d2df150d0c780200f0cefa2" })
  use({
    "winston0410/range-highlight.nvim",
    requires = { { "winston0410/cmd-parser.nvim", commit = "6363b8b" } },
    commit = "8b5e8ccb3460b2c3675f4639b9f54e64eaab36d9",
  })
  use({ "mbbill/undotree", commit = "36ff7abb6b60980338344982ad4cdf03f7961ecd" })
  use({ "tamago324/lir.nvim", commit = "969e95bd07ec315b5efc53af69c881278c2b74fa" })
  use({ "ton/vim-alternate", commit = "57a6d2797b3bec39f5c075104082b0c0835535ed" })

  -- Code
  use({ "ludovicchabant/vim-gutentags", commit = "aa47c5e29c37c52176c44e61c780032dfacef3dd" })
  use({ "arkav/lualine-lsp-progress", commit = "56842d097245a08d77912edf5f2a69ba29f275d7" }) -- is used?
  use({ "nvim-lua/lsp-status.nvim", commit = "54f48eb5017632d81d0fd40112065f1d062d0629" })
  use({ "neovim/nvim-lspconfig", commit = "694aaec65733e2d54d393abf80e526f86726c988" })
  use({ "lervag/vimtex", commit = "941485f8b046ac00763dad2546f0701e85e5e02c" })
  use({
    "pmizio/typescript-tools.nvim",
    commit = "7911a0aa27e472bff986f1d3ce38ebad3b635b28",
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  })

  use({ "jose-elias-alvarez/null-ls.nvim", requires = { "nvim-lua/plenary.nvim" }, commit = "0010ea927ab7c09ef0ce9bf28c2b573fc302f5a7" })

  -- Debugging/testing
  use({
    "nvim-neotest/neotest",
    requires = {
      { "mclaughlinconnor/neotest-mocha", commit = "deefd4119df8707d10a50ec3d31628ce6e64d40c" },
      { "jbyuki/one-small-step-for-vimkind", commit = "94b06d81209627d0098c4c5a14714e42a792bf0b" },
    },
    commit = "d424d262d01bccc1e0b038c9a7220a755afd2a1f",
  })
  use({ "folke/neodev.nvim", commit = "1676d2c24186fc30005317e0306d20c639b2351b" })
  use({ "mxsdev/nvim-dap-vscode-js", requires = { "mfussenegger/nvim-dap" }, commit = "03bd29672d7fab5e515fc8469b7d07cc5994bbf6" })
  use({
    "microsoft/vscode-js-debug",
    commit = "636f7e3f7c0204c370a46c6a76e1b6b688f41a85",
    opt = true,
    run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
  })
  use({ "mfussenegger/nvim-dap", commit = "13ce59d4852be2bb3cd4967947985cb0ceaff460", requires = { { "rcarriga/nvim-dap-ui", commit = "34160a7ce6072ef332f350ae1d4a6a501daf0159" } } })
  use({ "theHamsta/nvim-dap-virtual-text", commit = "57f1dbd0458dd84a286b27768c142e1567f3ce3b" })

  -- Completion
  use({ "L3MON4D3/LuaSnip", run = "make install_jsregexp", commit = "118263867197a111717b5f13d954cd1ab8124387" })
  use({ "amarakon/nvim-cmp-buffer-lines", commit = "924ccc04dc5c919b6baa05d45818025baa82699a" })
  use({ "dmitmel/cmp-cmdline-history", commit = "003573b72d4635ce636234a826fa8c4ba2895ffe" })
  use({ "doxnit/cmp-luasnip-choice", commit = "97a367851bc17984b56164b5427a53919aed873a" })
  use({ "f3fora/cmp-spell", commit = "32a0867efa59b43edbb2db67b0871cfad90c9b66" })
  use({ "hrsh7th/cmp-buffer", commit = "3022dbc9166796b644a841a02de8dd1cc1d311fa" })
  use({ "hrsh7th/cmp-calc", commit = "ce91d14d2e7a8b3f6ad86d85e34d41c1ae6268d9" })
  use({ "hrsh7th/cmp-cmdline", commit = "8ee981b4a91f536f52add291594e89fb6645e451" })
  use({ "hrsh7th/cmp-nvim-lsp", commit = "44b16d11215dce86f253ce0c30949813c0a90765" })
  use({ "hrsh7th/cmp-omni", commit = "4ef610bbd85a5ee4e97e09450c0daecbdc60de86" })
  use({ "hrsh7th/cmp-path", commit = "91ff86cd9c29299a64f968ebb45846c485725f23" })
  use({ "hrsh7th/nvim-cmp", commit = "0b751f6beef40fd47375eaf53d3057e0bfa317e4" })
  use({ "ray-x/cmp-treesitter", commit = "b8bc760dfcc624edd5454f0982b63786a822eed9" })
  use({ "rcarriga/cmp-dap", commit = "d16f14a210cd28988b97ca8339d504533b7e09a4" })
  use({ "saadparwaiz1/cmp_luasnip", commit = "05a9ab28b53f71d1aece421ef32fee2cb857a843" })
  use({ "FelipeLema/cmp-async-path", commit = "d8229a93d7b71f22c66ca35ac9e6c6cd850ec61d" })
  use({ "delphinus/cmp-ctags", commit = "8d9ddae9ea20c303bdc0888b663c0459b0dc72c2" })

  -- Plugin management
  use({ "williamboman/mason.nvim", commit = "41e75af1f578e55ba050c863587cffde3556ffa6" })
  use({ "wbthomason/packer.nvim", commit = "ea0cc3c59f67c440c5ff0bbe4fb9420f4350b9a3" })
  use({ "williamboman/mason-lspconfig.nvim", commit = "4eb8e15e3c0757303d4c6dea64d2981fc679e990" })

  -- Git
  use({ "kdheepak/lazygit.nvim", commit = "de35012036d43bca03628d40d083f7c02a4cda3f" })
  use({ "lewis6991/gitsigns.nvim", commit = "6ef8c54fb526bf3a0bc4efb0b2fe8e6d9a7daed2" })
  use({
    "mclaughlinconnor/diffview.nvim",
    rocks = { "luautf8", "lrexlib-pcre2" },
    requires = { "nvim-lua/plenary.nvim" },
    commit = "44a5b386b21a6704d28a027ca819a837b1968df8",
  })

  -- Theming
  use({ "gbprod/nord.nvim", commit = "2948bddbc3cf202789a37b38237144b290b432f6" })
  use({
    "nvim-lualine/lualine.nvim",
    commit = "2248ef254d0a1488a72041cfb45ca9caada6d994",
    requires = { "kyazdani42/nvim-web-devicons", opt = true, commit = "5efb8bd06841f91f97c90e16de85e96d57e9c862" },
  })

  -- Enable only in pug files
  use({ "lukas-reineke/indent-blankline.nvim", commit = "dbd90bb689ff10d21fee6792eb8928f0584b5860" })
  use({ "folke/tokyonight.nvim", commit = "f247ee700b569ed43f39320413a13ba9b0aef0db" })
  use({ "ldelossa/buffertag", commit = "59df48544585695da3439d78f3d816461797c592" })

  -- Tree
  use({ "nvim-treesitter/playground", commit = "ba48c6a62a280eefb7c85725b0915e021a1a0749" }) -- deprecated
  use({ "nvim-treesitter/nvim-treesitter", commit = "80a16deb5146a3eb4648effccda1ab9f45e43e76" })
  use({ "https://gitlab.com/HiPhish/rainbow-delimiters.nvim", commit = "47404636a34580db1636dc0cf35027bdf77abba5" })
  use({ "nvim-treesitter/nvim-treesitter-textobjects", commit = "ec1c5bdb3d87ac971749fa6c7dbc2b14884f1f6a" })

  -- Telescope
  use({ "stevearc/dressing.nvim", commit = "8b7ae53d7f04f33be3439a441db8071c96092d19" })
  use({
    "ibhagwan/fzf-lua",
    commit = "a1a2d0f42eaec400cc6918a8e898fc1f9c4dbc5f",
  })

  -- Curr
  use({ "TimUntersberger/neogit", commit = "d0e87541130b2cf62d7f8a54487ef99560232fb6", requires = "nvim-lua/plenary.nvim" })

  use({ "github/copilot.vim", commit = "2c31989063b145830d5f0bea8ab529d2aef2427b" })
  use({ "Exafunction/codeium.vim", commit = "2a0c0b7fecee38a52fe750563ff70cff45f768b0" })

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
