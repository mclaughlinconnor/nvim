require("nvim-dap-virtual-text").setup({
  enabled = true,
  only_first_definition = false,
  all_references = true,
  all_frames = true,
})

local widgets = require("dap.ui.widgets")
local dapui = require("dapui")
local dap = require("dap")

require("dap-vscode-js").setup({
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
})

for _, language in ipairs({ "typescript", "javascript" }) do
  dap.configurations[language] = {
    {
      name = "Launch Chrome",
      type = "pwa-chrome",
      request = "launch",
      url = "http://localhost:4200/#",
      webRoot = "${workspaceFolder}",
    },
    {
      name = "Attach Chrome",
      type = "pwa-chrome",
      request = "attach",
      url = "http://localhost:4200/#",
      webRoot = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }
end

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>du", function()
  dapui.toggle({})
end, opts)
vim.keymap.set("n", "<leader>dx", function()
  dap.terminate()
end, opts)
vim.keymap.set("n", "<leader>dd", function()
  dap.disconnect()
end, opts)

vim.keymap.set("n", "<leader>dc", function()
  dap.continue()
end, opts)
vim.keymap.set("n", "<leader>dR", function()
  dap.run_to_cursor()
end, opts)
vim.keymap.set("n", "<leader>dp", function()
  dap.pause.toggle()
end, opts)

vim.keymap.set("n", "<leader>db", function()
  dap.toggle_breakpoint()
end, opts)
vim.keymap.set("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input({ prompt = "[Condition] > " }))
end, opts)

vim.keymap.set("n", "<leader>dr", function()
  dap.repl.toggle()
end, opts)
vim.keymap.set("n", "<leader>dE", function()
  dapui.eval(vim.fn.input({ prompt = "[Expression] > " }), {})
end, opts)
vim.keymap.set("n", "<leader>de", function()
  -- This fine as per the docs :h dapui.eval
  ---@diagnostic disable-next-line: param-type-mismatch
  dapui.eval(nil, {})
end, opts)
vim.keymap.set("v", "<leader>de", function()
  -- This fine as per the docs :h dapui.eval
  ---@diagnostic disable-next-line: param-type-mismatch
  dapui.eval(nil, {})
end, opts)

vim.keymap.set("n", "<leader>dh", function()
  widgets.cursor_float(widgets.expression)
end, opts)
vim.keymap.set("n", "<leader>dH", function()
  widgets.centered_float(widgets.expression)
end, opts)

vim.keymap.set("n", "<leader>di", function()
  dap.step_into()
end, opts)
vim.keymap.set("n", "<leader>dv", function()
  dap.step_over()
end, opts)
vim.keymap.set("n", "<leader>do", function()
  dap.step_out()
end, opts)

dapui.setup()

vim.cmd([[
  augroup dap_float
    autocmd!
    autocmd FileType dap-float nnoremap <buffer><silent> q <cmd>close!<CR>
  augroup end
]])
