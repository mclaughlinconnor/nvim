return function()
  local opts = { path_shorten = true }

  opts.actions = require("fzf-lua").defaults.actions.files
  opts.previewer = "builtin"
  opts.fn_transform = function(x)
    return require("fzf-lua").make_entry.file(x, opts)
  end

  require("fzf-lua").fzf_live(function(args)
    local query = args[1]

    if query == "" or query == nil then
      return ""
    end

    local cmd_string =
      [[rg -i --color never --type yaml "(\w+)(:.*<query>.*)" --no-heading --no-filename --no-line-number --replace '$1' | parallel --colsep '\0' rg {} --color never --no-heading --line-number --column -g "\*.pug" ./]]
    local final = (cmd_string):gsub("<query>", query)

    return final
  end, opts)
end
