vim.cmd.colorscheme("nord")

vim.opt.termguicolors = true

require("ibl").setup({
  enabled = true,
  -- Debug why scope highlighting isn't working properly
  scope = {
    enabled = false,
    include = {
      node_type = {
        pug = {
          "tag",
          "content",
          "attributes",
        },
      },
    },
  },
})

local setColour = function(colour)
  vim.cmd.colorscheme(colour)
  -- Same as default, except with `Cursor` added in to change the highlight group
  vim.cmd([[
    set guicursor=n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor
  ]])
end

vim.api.nvim_create_user_command("FlashBang", function()
  setColour("tokyonight-day")
  -- Makes the diff colour **much** better
  vim.cmd([[highlight DiffAdd guibg=#a4cf69]])
  vim.cmd([[highlight DiffChange guibg=#63c1e6]])
  vim.cmd([[highlight DiffDelete guibg=#d74f56]])
end, {})

vim.api.nvim_create_user_command("LightsOut", function()
  setColour("nord")
end, {})
