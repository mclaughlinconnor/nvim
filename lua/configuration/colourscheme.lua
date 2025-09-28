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

    highlight DiagnosticUnderlineHint gui=none
    highlight DiagnosticUnderlineInfo gui=none

    highlight DiagnosticUnderlineWarn gui=underline
    highlight DiagnosticUnderlineError gui=underline
  ]])
end

return {
  {
    "gbprod/nord.nvim",
    commit = "57fb474a1d628bdf9d1e7964719464ed5675d7c7",
    -- event = "",
    config = function()
      -- setColour("delek")
      vim.cmd([[
        function! s:SetDiffHighlights() 
          if &background == "dark" 
            highlight DiffAdd gui=bold guifg=none guibg=#2e4b2e 
            highlight DiffDelete gui=bold guifg=none guibg=#4c1e15 
            highlight DiffChange gui=bold guifg=none guibg=#45565c 
            highlight DiffText gui=bold guifg=none guibg=#996d74 
          else 
            highlight DiffAdd gui=bold guifg=none guibg=lightgreen
            highlight DiffDelete gui=bold guifg=none guibg=lightred 
            highlight DiffChange gui=bold guifg=none guibg=lightblue 
            highlight DiffText gui=bold guifg=none guibg=lightcyan 
          endif 
        endfunction

        augroup diffcolors 
          autocmd! 
          autocmd Colorscheme * call s:SetDiffHighlights() 
        augroup END
      ]])

      setColour("nord")
      vim.cmd([[highlight SignColumn guifg=#FFFFFF]])

      vim.api.nvim_create_user_command("LightsOut", function()
        vim.o.background = "dark"
        setColour("nord")
        vim.cmd([[highlight SignColumn guifg=#FFFFFF]])
      end, {})

      vim.api.nvim_create_user_command("FlashBang", function()
        vim.o.background = "light"
        setColour("delek")
        vim.cmd([[highlight NormalFloat guibg=LightGray guifg=Black]])
        vim.cmd([[highlight DiagnosticInfo guifg=Blue]])
        vim.cmd([[highlight DiagnosticHint guifg=Grey]])

        vim.cmd([[highlight DiagnosticFloatingInfo guifg=Blue]])
        vim.cmd([[highlight DiagnosticFloatingHint guifg=Grey]])
        vim.cmd([[highlight DiagnosticFloatingWarn guifg=Orange]])
        vim.cmd([[highlight DiagnosticFloatingError guifg=Red]])
      end, {})
    end,
    dependencies = {
      "nvim-lualine/lualine.nvim" -- highlight customisations need to come after the highlights have been loaded
    }
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    commit = "005b56001b2cb30bfa61b7986bc50657816ba4ba",
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
