return {
  {
    "ldelossa/buffertag",
    commit = "59df48544585695da3439d78f3d816461797c592",
    config = function()
      local buffertag = require("buffertag")
      buffertag.setup({})
      buffertag.toggle()
    end,
  },
}
