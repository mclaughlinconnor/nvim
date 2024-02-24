local function astGrepToFile(result)
  local status, parsed = pcall(vim.json.decode, result)

  if not status then
    return nil
  end

  if parsed.lines == nil then
    return nil
  end

  local text = parsed.lines:gsub("\n", ""):gsub("  ", "")
  return require'fzf-lua'.utils.ansi_codes.magenta(parsed.file) .. ":" .. parsed.range.start.line + 1 .. ":" .. parsed.range["start"].column + 1 .. ":" .. text
end

return function()
  local opts = { path_shorten = true }

  opts.actions = require("fzf-lua").defaults.actions.files
  opts.previewer = "builtin"
  opts.fn_transform = function(x)
    local file = astGrepToFile(x)
    if file == nil then
      return nil
    end

    return require("fzf-lua").make_entry.file(file, opts)
  end

  require("fzf-lua").fzf_live(function(query)
    -- query = [[$X.aggregate]]
    local cmd_string =
      [[ast-grep --pattern '<query>' --lang "pug" --config ~/.config/nvim/misc/ast-grep/sgconfig.yml typescript--json=stream | head -n 200]]
    return (cmd_string):gsub("<query>", query)
  end, opts)
end
