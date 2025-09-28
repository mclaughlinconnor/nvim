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
    commit = "23320e75953ac82e559c610bec5a90d9c6dfa743",
    config = true,
  },
}
