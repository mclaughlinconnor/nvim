local createUpdateScript = function()
  local paths = vim.split(vim.fn.glob("./updates/org/*.ts"), "\n")

  local max = -1

  for i, file in pairs(paths) do
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
    vim.fn.writefile({ "// Bespoke:", "", "module.exports = async () => {", "  ", "}" }, filename)
  end

  local createFilename = function(name)
    filename = "./updates/org/" .. filenumber .. "-" .. (name):gsub(" ", "-"):lower() .. ".ts"
  end

  local openFile = function()
    vim.cmd.edit(filename)
    vim.fn.setpos(".", { 0, 4, 3, 1 })
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
