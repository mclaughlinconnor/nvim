require("nvim-dap-virtual-text").setup({
  enabled = true,
  only_first_definition = false,
  all_references = true,
  all_frames = true,
})

local widgets = require("dap.ui.widgets")
local dapui = require("dapui")
local dap = require("dap")

dap.configurations.lua = {
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance",
  },
}

dap.adapters.nlua = function(callback, config)
  callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
end

local firefoxPath = vim.fn.stdpath("data") .. "/mason/packages/firefox-debug-adapter"

dap.adapters.firefox = {
  type = "executable",
  command = "node",
  args = { firefoxPath .. "/dist/adapter.bundle.js" },
}

require("dap-vscode-js").setup({
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
})

for _, language in ipairs({ "typescript", "javascript" }) do
  dap.configurations[language] = {
    {
      name = "Chrome",
      type = "pwa-chrome",
      request = "launch",
      url = "http://localhost:4200/",
      webRoot = "${workspaceFolder}",
    },
    {
      keepProfileChanges = true,
      name = "Firefox",
      pathMappings = {
        {
          url = "webpack:///assets",
          path = "${workspaceFolder}/assets",
        },
      },
      profileDir = "/home/connorm/snap/firefox/common/.cache/mozilla/firefox/debug/", -- platform specific :(
      request = "launch",
      skipFiles = {
        "<node_internals>/**",
      },
      timeout = 20,
      tmpDir = firefoxPath .. "/temp",
      type = "firefox",
      url = "http://localhost:4200/",
      webRoot = "${workspaceFolder}",
    },
    {
      continueOnAttach = true,
      cwd = "${workspaceFolder}",
      name = "Server",
      outputCapture = "std",
      port = 9229,
      request = "launch",
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
      runtimeArgs = {
        "run-script",
        "debug",
      },
      runtimeExecutable = "npm",
      skipFiles = {
        "<node_internals>/**",
      },
      smartStep = true,
      type = "pwa-node",
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
