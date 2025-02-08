local createUpdateScript = function(path, lnum)
  path = path or "org"
  lnum = lnum or 4

  local paths = vim.split(vim.fn.glob("./updates/" .. path .. "/*.ts"), "\n")

  local max = -1

  for _, file in pairs(paths) do
    local number = tonumber(vim.fn.fnamemodify(file, ":t"):match("%d%d%d%d"))

    if number ~= nil and number > max then
      max = number
    end
  end

  if max == -1 then
    vim.notify("smh you've gotta be in a vc repo for that to work")
    return
  end

  local filenumber = ("%04d"):format(max + 1)
  local filename = ""

  local createFile = function()
    local lines = { "module.exports = async () => {", "  ", "}" }
    if (path == "org") then
      -- Insert at 0, so it's reverse order
      table.insert(lines, 1, "")
      table.insert(lines, 1, "// Bespoke:")
    end

    vim.fn.writefile(lines, filename)
  end

  local createFilename = function(name)
    filename = "./updates/" .. path .. "/" .. filenumber .. "-" .. (name):gsub(" ", "-"):lower() .. ".ts"
  end

  local openFile = function()
    vim.cmd.edit(filename)
    vim.fn.setpos(".", { 0, lnum, 3, 1 })
  end

  vim.ui.input({ prompt = "Enter file name: " }, function(input)
    if input == nil then
      vim.notify("smh you've gotta give me a filename to work with")
      return
    end

    createFilename(input)
    createFile()
    openFile()
  end)
end

local bufopts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>vu", createUpdateScript, bufopts)
vim.keymap.set("n", "<leader>vU", function() createUpdateScript("master", 2) end, bufopts)
