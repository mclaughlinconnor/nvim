local setColour = function(colour)
  vim.cmd.colorscheme(colour)
  -- Same as default, except with `Cursor` added in to change the highlight group
  vim.cmd([[
    set guicursor=n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor
  ]])
end

return {
  {
    "gbprod/nord.nvim",
    commit = "2948bddbc3cf202789a37b38237144b290b432f6",
    lazy = false,
    priority = 1000, -- load first
    config = function()
      vim.cmd.colorscheme("nord")

      vim.api.nvim_create_user_command("LightsOut", function()
        setColour("nord")
      end, {})
    end,
  },
  {
    "folke/tokyonight.nvim",
    commit = "f247ee700b569ed43f39320413a13ba9b0aef0db",
    lazy = false,
    config = function()
      vim.api.nvim_create_user_command("FlashBang", function()
        setColour("tokyonight-day")
        -- Makes the diff colour **much** better
        vim.cmd([[highlight DiffAdd guibg=#a4cf69]])
        vim.cmd([[highlight DiffChange guibg=#63c1e6]])
        vim.cmd([[highlight DiffDelete guibg=#d74f56]])
      end, {})
    end,
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
