local oil = require("oil")
local file_generators = require("user.component_generators")

local function get_name(callback)
  vim.ui.input({ prompt = "What should the selector of your component be?" }, function(selector)
    callback((selector):gsub("^tg%-", ""):gsub(" ", "-"):lower())
  end)
end

local function make_directory(directory, selector)
  local path = directory .. "/" .. selector
  vim.fn.mkdir(path)

  return path
end

local function make_component(component_directory, component_class_name, selector)
  local extensions = { ".ts", ".scss", ".pug" }

  local fd
  for _, extension in ipairs(extensions) do
    local file_path = component_directory .. "/" .. selector .. ".component" .. extension

    fd = vim.loop.fs_open(file_path, "w+", 436)

    if fd == nil then
      vim.notify("Couldn't open " .. file_path)
      return
    end

    vim.loop.fs_write(fd, file_generators.the_only_type[extension](component_class_name, selector))
  end
end

local oilComponent = vim.api.nvim_create_augroup("OilAngular", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
  callback = function()
    vim.keymap.set("n", "<leader>vn", function()
      local directory = oil.get_current_dir()

      get_name(function(selector)
        local component_class_name = selector:gsub("-(.)", string.upper):gsub("^%l", string.upper)
        local component_directory = make_directory(directory, selector)
        make_component(component_directory, component_class_name, selector)

        oil.open(component_directory)
      end)
    end, { noremap = true, buffer = 0 })
  end,
  group = oilComponent,
  pattern = "oil",
})
