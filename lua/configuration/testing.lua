-- https://github.com/microsoft/vscode-recipes/blob/main/debugging-mocha-tests/README.md

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      { "mclaughlinconnor/neotest-mocha", commit = "deefd4119df8707d10a50ec3d31628ce6e64d40c" },
      { "jbyuki/one-small-step-for-vimkind", commit = "94b06d81209627d0098c4c5a14714e42a792bf0b" },
    },
    commit = "deadfb1af5ce458742671ad3a013acb9a6b41178",
    opts = function()
      local vc_config = {
        adapters = {
          require("neotest-mocha")({
            command = "node_modules/.bin/mocha --exit -require source-map-support/register --require ./.src/test.bootstrap.js --recursive ./test/tests",
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

      return {
        log_level = vim.log.levels.DEBUG,
        projects = {
          ["~/vc/repos/development"] = vc_config,
          ["~/vc/repos/client"] = vc_config,
        },
        summary = {
          follow = true,
        },
      }
    end,
  },
}
