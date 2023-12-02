local lang_utils = require("treesj.langs.utils")
local ts = require("treesj.langs.typescript")
local pug = require("treesj.langs.pug")

require("treesj").setup({
  langs = {
    pug = lang_utils.merge_preset(pug, {
      attributes = lang_utils.set_preset_for_args({
        split = { separator = "," },
        join = { separator = "," },
      }),
    }),
    typescript = lang_utils.merge_preset(ts, {
      object_type = lang_utils.set_preset_for_dict({
        split = { separator = ";", last_separator = true },
        join = { separator = ";", last_separator = true, space_in_brackets = false },
      }),
      object = lang_utils.set_preset_for_dict({
        join = { space_in_brackets = false },
      }),
      array = lang_utils.set_preset_for_dict({
        join = { space_in_brackets = false },
      }),
      formal_parameters = lang_utils.set_preset_for_list({
        join = { separator = ",", last_separator = false, space_in_brackets = false },
        split = { separator = ",", last_separator = false },
      }),
    }),
  },
})

vim.keymap.set("n", "<leader>j", function()
  require("treesj").toggle()
end)

vim.keymap.set("n", "<leader>J", function()
  require("treesj").toggle({ recursive = true })
end)
