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
  [
    (public_field_definition
      (accessibility_modifier) @accessibility_modifier
      name: (property_identifier) @var) @definition
    (required_parameter
      (accessibility_modifier) @accessibility_modifier
      pattern: (identifier) @var) @definition
  ]
]]

M.raw_queries.getter_definition = [[
  (method_definition
    (accessibility_modifier) @accessibility_modifier
    "get"
    name: (property_identifier) @var)
]]

M.raw_queries.prototype_usage = [[
  [
    (member_expression
      object: (member_expression
        object: (identifier) @class
        property: (property_identifier) @prototype)
      property: (property_identifier) @var)
    (subscript_expression
      object: (member_expression
        object: (identifier) @class
        property: (property_identifier) @prototype)
      index: (string
        (string_fragment) @var))
    (#eq? @prototype "prototype")
    ; (#eq? @class "class") ; add later when class checking is supported
  ]
]]

M.raw_queries.property_usage = [[
  (member_expression
    object: (this)
    property: (property_identifier) @var)
]]

M.raw_queries.class_decorator = [[
  [
    (export_statement
      decorator: (decorator
        (call_expression
          function: (identifier) @decorator_name))
      declaration: (class_declaration))
    (class_declaration
      decorator: (decorator
        (call_expression
          function: (identifier) @decorator_name)))
  ]
]]

M.raw_queries.component_decorator = [[
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

M.raw_queries.class_definition = [[
  [
    (export_statement
      decorator: (decorator)
      declaration: (class_declaration
        name: (type_identifier) @name
        body: (class_body))) @class
    (class_declaration
      decorator: (decorator)
      name: (type_identifier) @name
      body: (class_body)) @class
  ]
]]

M.attributes = vim.treesitter.query.parse("pug", M.raw_queries.attributes)
M.content = vim.treesitter.query.parse("pug", M.raw_queries.content)
M.interpolation = vim.treesitter.query.parse("angular_content", M.raw_queries.interpolation)
M.identifiers = vim.treesitter.query.parse("javascript", M.raw_queries.identifiers)
M.property_definition = vim.treesitter.query.parse("typescript", M.raw_queries.property_definition)
M.getter_definition = vim.treesitter.query.parse("typescript", M.raw_queries.getter_definition)
M.prototype_usage = vim.treesitter.query.parse("typescript", M.raw_queries.prototype_usage)
M.property_usage = vim.treesitter.query.parse("typescript", M.raw_queries.property_usage)
M.component_decorator = vim.treesitter.query.parse("typescript", M.raw_queries.component_decorator)
M.class_definition = vim.treesitter.query.parse("typescript", M.raw_queries.class_definition)
M.class_decorator = vim.treesitter.query.parse("typescript", M.raw_queries.class_decorator)

return M
