return {
  {
    "Wansmer/treesj",
    commit = "1d6e89f4790aa04eaae38fa9460a3ee191961c96",
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
            array = utils.set_preset_for_dict({
              join = { space_in_brackets = false },
            }),
            formal_parameters = utils.set_preset_for_list({
              join = { separator = ",", last_separator = false, space_in_brackets = false },
              split = { separator = ",", last_separator = false },
            }),
          }),
        },
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
