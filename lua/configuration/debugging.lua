return {
  {
    "theHamsta/nvim-dap-virtual-text",
    commit = "57f1dbd0458dd84a286b27768c142e1567f3ce3b",
    opts = {
      all_frames = true,
      all_references = true,
      enabled = true,
      only_first_definition = false,
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    commit = "34160a7ce6072ef332f350ae1d4a6a501daf0159",
    config = function()
      require("dapui").setup()

      local dap_float = vim.api.nvim_create_augroup("dap_float", { clear = true })
      vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        pattern = "dap-float",
        group = dap_float,
        callback = function()
          vim.keymap.set("n", "q", vim.cmd.close)
        end,
      })
    end,
  },
  {
    "mxsdev/nvim-dap-vscode-js",
    commit = "03bd29672d7fab5e515fc8469b7d07cc5994bbf6",
    dependencies = { "microsoft/vscode-js-debug" },
    opts = {
      adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
    },
  },
  {
    "microsoft/vscode-js-debug",
    commit = "636f7e3f7c0204c370a46c6a76e1b6b688f41a85",
    lazy = true,
    build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
  },
  {
    "mfussenegger/nvim-dap",
    commit = "13ce59d4852be2bb3cd4967947985cb0ceaff460",
    dependencies = { "rcarriga/nvim-dap-ui", "mfussenegger/nvim-dap", "mxsdev/nvim-dap-vscode-js" },
    config = function()
      local dap = require("dap")

      dap.configurations["lua"] = {
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
          {
            type = "pwa-node",
            request = "launch",
            name = "Current file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle({})
        end,
        desc = "Toggle DAP UI",
      },
      {
        "<leader>dx",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate DAP session",
      },
      {
        "<leader>dd",
        function()
          require("dap").disconnect()
        end,
        desc = "Disconnect from DAP sesion",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue DAP session",
      },
      {
        "<leader>dR",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run DAP execution to cursor",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "Pause DAP execution",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle DAP breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input({ prompt = "[Condition] > " }))
        end,
        desc = "Toggle conditional DAP breakpoint",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle DAP REPL",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle DAP REPL",
      },
      {
        "<leader>dE",
        function()
          -- This fine :h require("require("dap").ui").eval
          ---@diagnostic disable-next-line: missing-fields
          require("dapui").eval(vim.fn.input({ prompt = "[Expression] > " }), {})
        end,
        desc = "Evalute an expression",
      },
      {
        "<leader>de",
        function()
          -- This fine :h require("require("dap").ui").eval
          ---@diagnostic disable-next-line: missing-fields
          require("dapui").eval(nil, {})
        end,
        desc = "Evalute the word under the cursor",
      },
      {
        "<leader>dh",
        function()
          local widgets = require("dapui.widgets")
          widgets.cursor_float(widgets.expression)
        end,
        desc = "Hover expression in float",
      },
      {
        "<leader>dH",
        function()
          local widgets = require("dapui.widgets")
          widgets.centered_float(widgets.expression)
        end,
        desc = "Hover expression in big float",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "DAP step into",
      },
      {
        "<leader>dv",
        function()
          require("dap").step_over()
        end,
        desc = "DAP step over",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "DAP step out",
      },
    },
  },
}
