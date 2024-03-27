local M = {raw_queries = {}}

M.raw_queries.attributes = [[
  (attribute
    (attribute_name) @name
    (quoted_attribute_value
      (attribute_value) @value))
]]

M.raw_queries.content = [[
  (content) @content
]]

M.raw_queries.interpolation = [[
  (interpolation) @interpolation
]]

M.raw_queries.identifiers = [[
  (identifier) @name
]]

M.raw_queries.property_definition = [[
  (public_field_definition
    (accessibility_modifier) @accessibility_modifier
    name: (property_identifier) @var) @definition
]]

M.raw_queries.getter_definition = [[
  (method_definition
    (accessibility_modifier) @accessibility_modifier
    "get"
    name: (property_identifier) @var)
]]

M.raw_queries.property_usage = [[
  (member_expression
    object: (this)
    property: (property_identifier) @var)
]]

M.raw_queries.template = [[
  (decorator
    (call_expression
      function: (identifier) @decorator_name
      arguments: (arguments
        (object
          (pair
             key: (property_identifier) @key_name
             value: (string (string_fragment) @template)
          )
        )
      )
    )
    (#eq? @key_name "templateUrl")
    (#eq? @decorator_name "Component")
  )
]]

M.attributes = vim.treesitter.query.parse("pug", M.raw_queries.attributes)
M.content = vim.treesitter.query.parse("pug", M.raw_queries.content)
M.interpolation = vim.treesitter.query.parse("angular_content", M.raw_queries.interpolation)
M.identifiers = vim.treesitter.query.parse("javascript", M.raw_queries.identifiers)
M.property_definition = vim.treesitter.query.parse("typescript", M.raw_queries.property_definition)
M.getter_definition = vim.treesitter.query.parse("typescript", M.raw_queries.getter_definition)
M.property_usage = vim.treesitter.query.parse("typescript", M.raw_queries.property_usage)
M.template = vim.treesitter.query.parse("typescript", M.raw_queries.template)

return M
