return {
  {
    "machakann/vim-sandwich",
    commit = "c5a2cc438ce6ea2005c556dc833732aa53cae21a",
    config = function()
      vim.cmd([[call operator#sandwich#set('all', 'all', 'hi_duration', 30)]])
    end,
  },
  {
    "windwp/nvim-autopairs",
    commit = "0f04d78619cce9a5af4f355968040f7d675854a1",
  },
}
