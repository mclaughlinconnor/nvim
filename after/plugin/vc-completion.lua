local source = {}

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available()
  return true
end

---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
  local cmd =
    [[cat assets/appv2/static-routes.generated.ts | tr -d '\n' | awk '{print substr($0, 194, length-194)}' | jq '.[].name' | tr -d '"']]

  local results = vim.fn.systemlist(cmd)
  local items = {}
  for _, line in ipairs(results) do
    table.insert(items, { label = line })
  end
  callback({ items = items })
end

---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
  local cmd = [[cat assets/appv2/static-routes.generated.ts | tr -d '\n' | awk '{print substr($0, 194, length-194)}' | jq '.[] | select(.name == "]]
    .. completion_item.label
    .. [[").url']]

  local result = vim.fn.system(cmd)
  completion_item.documentation = result
  callback(completion_item)
end

---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
  callback(completion_item)
end

---Register your source to nvim-cmp.
require("cmp").register_source("routes", source)
