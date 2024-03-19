local Job = require("plenary.job")

local jsonBuffer = "json"
local htmlBuffer = "html"
local pugBuffer = "pug"
local compiledBuffer = "compiled"

local function read_buffer(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return table.concat(lines, "\n")
end

-- Function to compile the Handlebars document
local function compile_handlebars(mode, jsonContent, pugBufnr, htmlBufnr, compiledBufnr)
  local pugTemplate = read_buffer(pugBufnr)
  local htmlTemplate = read_buffer(htmlBufnr)

  if (pugTemplate == "" and htmlTemplate == "") or jsonContent == "" then
    return
  end

  local template
  if mode == "pug" then
    template = read_buffer(pugBufnr)
  else
    template = read_buffer(htmlBufnr)
  end

  vim.api.nvim_buf_set_lines(compiledBufnr, 0, -1, false, {""})

  local path = vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/misc/handlebars/src/init.js"

  -- Replace the following command with your actual command
  local job = Job:new({
    command = "node",
    args = {path, mode, jsonContent},
    on_exit = function(job, return_val)
      vim.schedule(function()
        if return_val ~= 0 then
          return
        end

        local ok, results = pcall(vim.json.decode, table.concat(job:result(), "\n"))
        if not ok then
          vim.api.nvim_buf_set_lines(compiledBufnr, 0, -1, false, vim.split(results, "\n"))
          -- Should already be handled by the on_stderr callback
          return
        end

        if mode == "pug" then
          vim.api.nvim_buf_set_lines(htmlBufnr, 0, -1, false, vim.split(results.html, "\n"))
        else
          vim.api.nvim_buf_set_lines(pugBufnr, 0, -1, false, vim.split(results.pug, "\n"))
        end

        vim.api.nvim_buf_set_lines(compiledBufnr, 0, -1, false, vim.split(results.compiledTemplate, "\n"))
      end)
    end,
    on_stderr = function(_, error)
      if error == "" then
        return
      end

      vim.schedule(function()
        vim.api.nvim_buf_set_lines(compiledBufnr, -1, -1, false, vim.split(error, "\n"))
      end)
    end,
  })
  job:start()
  job:send(template)
  job.stdin:close()
end

local function open_buffer(name, split)
  if split == "vertical" then
    vim.cmd.vsplit()
  elseif split == "horizontal" then
    vim.cmd.split()
  end

  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.api.nvim_buf_set_name(bufnr, name)

  return bufnr
end

local function focusBuffer(bufnr)
  local winnr = vim.fn.bufwinid(bufnr)
  if winnr ~= -1 then
    vim.api.nvim_set_current_win(winnr)
  end
end

local function init()
  vim.cmd.tabnew()
  local pugBufnr = open_buffer(pugBuffer, false)
  local jsonBufnr = open_buffer(jsonBuffer, "horizontal")

  focusBuffer(pugBufnr)
  local htmlBufnr = open_buffer(htmlBuffer, "vertical")
  focusBuffer(jsonBufnr)
  local compiledBufnr = open_buffer(compiledBuffer, "vertical")

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = pugBufnr,
    callback = function()
      compile_handlebars("pug", read_buffer(jsonBufnr), pugBufnr, htmlBufnr, compiledBufnr)
    end,
    group = vim.api.nvim_create_augroup("PugHandlebars", {}),
  })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = htmlBufnr,
    callback = function()
      compile_handlebars("html", read_buffer(jsonBufnr), pugBufnr, htmlBufnr, compiledBufnr)
    end,
    group = vim.api.nvim_create_augroup("HtmlHandlebars", {}),
  })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = jsonBufnr,
    callback = function()
      compile_handlebars("pug", read_buffer(jsonBufnr), pugBufnr, htmlBufnr, compiledBufnr)
      compile_handlebars("html", read_buffer(jsonBufnr), pugBufnr, htmlBufnr, compiledBufnr)
    end,
    group = vim.api.nvim_create_augroup("CompiledHandlebars", {}),
  })
end

vim.keymap.set("n", "<leader>vh", function()
  init()
end)
