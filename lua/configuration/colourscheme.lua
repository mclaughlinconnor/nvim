local setColour = function(colour)
  vim.cmd.colorscheme(colour)
  -- Same as default, except with `Cursor` added in to change the highlight group
  vim.cmd([[
    set guicursor=n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor
  ]])

  vim.cmd([[
    highlight debugPC guibg=#000000
    highlight lualine_c_insert guifg=#FFFFFF
    highlight lualine_c_normal guifg=#FFFFFF
    highlight lualine_c_visual guifg=#FFFFFF
    highlight lualine_c_command guifg=#FFFFFF
    highlight lualine_c_replace guifg=#FFFFFF
    highlight lualine_c_inactive guifg=#FFFFFF
  ]])
end

return {
  {
    "gbprod/nord.nvim",
    commit = "70fc2425b50396e5f1230200b59527d8440a24df",
    lazy = false,
    priority = 1000, -- load first
    config = function()
      vim.cmd.colorscheme("nord")
      vim.cmd([[highlight SignColumn guifg=#FFFFFF]])

      vim.api.nvim_create_user_command("LightsOut", function()
        setColour("nord")
        vim.cmd([[highlight SignColumn guifg=#FFFFFF]])
      end, {})

      vim.api.nvim_create_user_command("FlashBang", function()
        setColour("delek")
      end, {})
    end,
    dependencies = {
      {"rose-pine/neovim"},
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    commit = "dbd90bb689ff10d21fee6792eb8928f0584b5860",
    config = function(_, opts)
      require("ibl").setup(opts)
      local indent_lines = vim.api.nvim_create_augroup("indent_lines", {})
      vim.api.nvim_create_autocmd({ "DiffUpdated" }, {
        callback = function()
          if vim.o.diff then
            require("ibl").update({ enabled = false })
          end
        end,
        group = indent_lines,
      })
    end,
    opts = {
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
    },
  },
  { "kyazdani42/nvim-web-devicons", lazy = true, commit = "5efb8bd06841f91f97c90e16de85e96d57e9c862" },
}
