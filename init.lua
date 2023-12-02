-- Current nvim HEAD: 17f3a3ae31d91944a5a4e56aa743745cff7fdf07

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
    performance = {
      rtp = {
        disabled_plugins = {
          "netrwPlugin",
        },
      },
    },
  }
)
