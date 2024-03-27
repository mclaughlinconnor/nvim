local utils = require("user.diagnostics.utils")

local M = {}

function M.extract_js_identifiers(text, cb)
  for node in utils.iter_matches("identifiers", text, nil, "javascript") do
    cb(node, text)
  end
end

return M
