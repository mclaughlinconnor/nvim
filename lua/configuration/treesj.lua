return {
  {
    "Wansmer/treesj",
    commit = "3b4a2bc42738a63de17e7485d4cc5e49970ddbcc",
    opts = function()
      local utils = require("treesj.langs.utils")

      return {
        langs = {
          pug = utils.merge_preset(require("treesj.langs.pug"), {
            attributes = utils.set_preset_for_args({
              split = { separator = "," },
              join = { separator = "," },
            }),
          }),
          typescript = utils.merge_preset(require("treesj.langs.typescript"), {
            object_type = utils.set_preset_for_dict({
              split = { separator = ";", last_separator = true },
              join = { separator = ";", last_separator = true, space_in_brackets = false },
            }),
            object = utils.set_preset_for_dict({
              join = { space_in_brackets = false },
            }),
            named_imports = utils.set_preset_for_dict({
              join = { space_in_brackets = false },
            }),
            array = utils.set_preset_for_dict({
              join = { space_in_brackets = false },
            }),
            formal_parameters = utils.set_preset_for_list({
              join = { separator = ",", last_separator = false, space_in_brackets = false },
              split = { separator = ",", last_separator = false },
            }),
          }),
        },
        max_join_length = 1000,
      }
    end,
    keys = {
      {
        "<leader>j",
        function()
          require("treesj").toggle()
        end,
      },
      {
        "<leader>J",
        function()
          require("treesj").toggle({ recursive = true })
        end,
      },
    },
  },
}
