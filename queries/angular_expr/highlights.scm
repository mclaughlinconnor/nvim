(identifier) @variable

(style_unit) @variable

(pipe_operator) @operator

(string) @string

(number) @number

(pipe_call
  name: (identifier) @function)

(pipe_call
  arguments: (pipe_arguments
    (identifier) @variable.parameter))

(member_expression
  property: (identifier) @property)

(call_expression
  function: (identifier) @function)

(call_expression
  function: ((identifier) @function.builtin
    (#eq? @function.builtin "$any")))

(pair
  key: ((identifier) @variable.builtin
    (#eq? @variable.builtin "$implicit")))

((identifier) @boolean
  (#any-of? @boolean "true" "false"))

((identifier) @variable.builtin
  (#any-of? @variable.builtin "this" "$event"))

((identifier) @constant.builtin
  (#eq? @constant.builtin "null"))

[
  (ternary_operator)
  (conditional_operator)
] @keyword.conditional.ternary

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

[
  "."
  ","
  "?."
] @punctuation.delimiter

(nullish_coalescing_expression
  (coalescing_operator) @operator)

(binary_expression
  [
    "-"
    "&&"
    "+"
    "<"
    "<="
    "="
    "=="
    "==="
    "!="
    "!=="
    ">"
    ">="
    "*"
    "/"
    "||"
    "%"
  ] @operator)
