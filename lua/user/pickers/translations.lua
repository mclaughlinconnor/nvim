return function()
  local opts = { path_shorten = true }

  opts.actions = require("fzf-lua").defaults.actions.files
  opts.previewer = "builtin"
  opts.fn_transform = function(x)
    return require("fzf-lua").make_entry.file(x, opts)
  end

  require("fzf-lua").fzf_live(function(query)
    local cmd_string =
      [[rg -i --color never --type yaml "(\w+)(:.*<query>.*)" --no-heading --no-filename --no-line-number --replace '$1' --null | parallel --colsep '\0' rg {} --color never --no-heading --line-number --column -g "\*.pug" ./]]
    return (cmd_string):gsub("<query>", query)
  end, opts)
end
