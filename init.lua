-- Current nvim HEAD: c3061a40f7012b4cd9afcaa6e8b856e946aed528

vim.loader.enable()

vim.filetype.add({
  extension = {
    hx = "haxe",
  },
})

require("user.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
  "configuration",
  {
    change_detection = { notify = false },
    performance = {
      rtp = {
        disabled_plugins = {
          "netrwPlugin",
        },
      },
    },
  }
)
