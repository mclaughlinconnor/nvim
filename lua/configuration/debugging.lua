return {
  { "stevearc/profile.nvim", commit = "0ee32b7aba31d84b0ca76aaff2ffcb11f8f5449f" },
  {
    "theHamsta/nvim-dap-virtual-text",
    commit = "df66808cd78b5a97576bbaeee95ed5ca385a9750",
    opts = {
      all_references = false,
      display_callback = function(variable, _, _, _, options)
        local value = variable.value
        if string.len(value) > 10 then
          return ""
        end

        if options.virt_text_pos == "inline" then
          return " = " .. value
        else
          return variable.name .. " = " .. value
        end
      end,
      enabled = true,
      only_first_definition = true,
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    commit = "727c032a8f63899baccb42a1c26f27687e62fc5e",
    config = function()
      require("dapui").setup()
      local dap_float = vim.api.nvim_create_augroup("dap_float", { clear = true })
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = "dap-float",
        group = dap_float,
        callback = function(event)
          vim.bo[event.buf].buflisted = false
          vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
        end,
      })
    end,
  },
  {
    "microsoft/vscode-js-debug",
    commit = "299d29f2a7b535115305068dfb531a7f37a05e44",
    lazy = true,
    build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && mv dist out",
  },
  {
    "leoluz/nvim-dap-go",
    opts = {
      dap_configurations = {
        {
          -- Must be "go" or it will be ignored by the plugin
          type = "go",
          name = "Attach remote",
          mode = "remote",
          request = "attach",
        },
      },
    },
  },
  {
    "leoluz/nvim-dap-go",
    commit = "5faf165f5062187320eaf9d177c3c1f647adc22e",
    opts = {
      dap_configurations = {
        {
          type = "go",
          name = "Debug main.go",
          request = "launch",
          program = "${workspaceFolder}/main.go"
        },
      }
    },
  },
  {
    "mfussenegger/nvim-dap",
    commit = "99807078c5089ed30e0547aa4b52c5867933f426",
    dependencies = { "rcarriga/nvim-dap-ui", "mfussenegger/nvim-dap", "microsoft/vscode-js-debug", "mxsdev/nvim-dap-vscode-js" },
    config = function()
      local dap = require("dap")
      -- dap.set_log_level('TRACE')

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

      if not dap.adapters["pwa-chrome"] then
        require("dap").adapters["pwa-chrome"] = {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = {
            command = "node",
            args = {
              require("mason-registry").get_package("js-debug-adapter"):get_install_path()
                .. "/js-debug/src/dapDebugServer.js",
              "${port}",
            },
          },
        }
      end

      if not dap.adapters["pwa-node"] then
        require("dap").adapters["pwa-node"] = {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = {
            command = "node",
            args = {
              require("mason-registry").get_package("js-debug-adapter"):get_install_path()
                .. "/js-debug/src/dapDebugServer.js",
              "${port}",
            },
          },
        }
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
            cwd = "${workspaceFolder}",
            name = "Server",
            trace = false,
            outputCapture = "std",
            port = 9229,
            request = "launch",
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
            runtimeArgs = {
              "--nolazy",
              "--inspect=9229",
              "-r",
              "source-map-support/register",
              ".src/app.js",
            },
            runtimeExecutable = "node",
            skipFiles = {
              "<node_internals>/**",
            },
            smartStep = true,
            type = "pwa-node",
          },
          {
            name = "Firefox",
            pathMappings = {
              {
                url = "webpack:///assets",
                path = "${workspaceFolder}/assets",
              },
            },
            profileDir = "/Users/connorveryconnect.com/Library/Application Support/Firefox/Profiles/t2i3rv3r.debug", -- platform specific :(
            request = "launch",
            skipFiles = {
              "<node_internals>/**",
            },
            timeout = 20,
            tmpDir = firefoxPath .. "/temp",
            type = "firefox",
            url = "http://localhost:1337/",
            webRoot = "${workspaceFolder}",
          },
          {
            name = "Chrome",
            type = "pwa-chrome",
            request = "launch",
            runtimeArgs = {
              "--profile-directory=debug-profile",
            },
            userDataDir = false,
            url = "http://localhost:1337",
            webRoot = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug backend tests",
            env = { NODE_ENV = "test" },
            program = "${workspaceFolder}/node_modules/mocha/bin/_mocha",
            runtimeArgs = {
              "--inspect",
            },
            args = {
              "--timeout",
              "999999",
              "--exit",
              "--full-trace",
              "-r",
              "source-map-support/register",
              "-r",
              "${workspaceFolder}/.src/test.bootstrap.js",
              "--recursive",
              "${workspaceFolder}/.src/test/tests",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
          },
          {
            name = "Attach frontend tests",
            port = 9222,
            request = "attach",
            type = "pwa-chrome",
            pathMapping = {
              ["/_karma_webpack_"] = "${workspaceFolder}",
            },
          },
          {
            console = "integratedTerminal",
            cwd = "${workspaceFolder}",
            name = "Launch frontend tests",
            outputCapture = "std",
            request = "launch",
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
            runtimeArgs = {
              "run-script",
              "test:frontend:watch",
              "--",
              "--karma-config",
              vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/after/plugin/vc-karma.js",
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
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }

        vim.keymap.set("n", "<leader><leader>dc", require("fzf-lua").dap_commands)
        vim.keymap.set("n", "<leader><leader>db", require("fzf-lua").dap_breakpoints)
        vim.keymap.set("n", "<leader><leader>df", require("fzf-lua").dap_frames)
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
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue DAP session",
      },
      {
        "<leader>dC",
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
          require("dap").restart_frame()
        end,
        desc = "Try to restart the frame. Use pause to recover from failure",
      },
      {
        "<leader>dR",
        function()
          require("dap").pause()
        end,
        desc = "Pause thread. Most often used to recover from failed stack restart",
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
          local widgets = require("dap.ui.widgets")
          widgets.cursor_float(widgets.expression)
        end,
        desc = "Hover expression in float",
      },
      {
        "<leader>dH",
        function()
          local widgets = require("dap.ui.widgets")
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
        "<leader>dt",
        function()
          require("dap").step_out()
        end,
        desc = "DAP step out",
      },
    },
  },
}
