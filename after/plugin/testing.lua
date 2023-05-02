local neotest = require("neotest")
local mocha = require("neotest-mocha")

local vc_config = {
  adapters = {
    mocha({
      command =
      "node_modules/.bin/mocha --exit -require source-map-support/register --require ./.src/test.bootstrap.js --recursive ./test/tests",
      env = {
        CI = true,
        NODE_ENV = "test",
      },
      cwd = function()
        return vim.fn.getcwd()
      end,
      is_test_file = function(file_path)
        return file_path:match(".*test/tests.*%.ts")
      end,
      dap = {
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
        skipFiles = {
          "<node_internals>/**",
        },
        smartStep = true,
      },
    }),
  },
  default_strategy = "integrated",
  running = {
    concurrent = false,
  },
}

neotest.setup({
  log_level = vim.log.levels.DEBUG,
  projects = {
    ["~/vc/repos/development"] = vc_config,
    ["~/vc/repos/client"] = vc_config,
  },
  summary = {
    follow = true,
  },
})
