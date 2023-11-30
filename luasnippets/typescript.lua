---Attempts to (in decreasing order of presedence):
-- - Convert a plural noun into a singular noun
-- - Return the first letter of the word
-- - Return "item" as a fallback
local function iteration_var_names(last_word)
  -- initialize with fallback
  local singular_word = "item"

  if string.match(last_word, ".s$") then
    -- assume the given input is plural if it ends in s. This isn't always
    -- perfect, but it's pretty good
    singular_word = string.gsub(last_word, "s$", "", 1)
  elseif string.match(last_word, "^_?%w.+") then
    -- include an underscore in the match so that inputs like '_name' will
    -- become '_n' and not just '_'
    singular_word = string.match(last_word, "^_?.")
  end

  return singular_word
end

local function singular(input)
  local plural_word = input[1][1]
  local last_word = string.match(plural_word, "[_%w]*$")

  -- initialize with fallback
  local singular_word = iteration_var_names(last_word)

  return s("{}", i(1, singular_word))
end

local ts_postfix_term = function(trigger, replacement)
  return treesitter_postfix({
    trig = trigger,
    reparseBuffer = "live",
    matchTSNode = {
      query = [[
        [
          (identifier)
          (property_identifier)
        ] @prefix
      ]],
      query_lang = "typescript",
      select = "longest",
    },
  }, {
    f(function(_, parent)
      local node_content = table.concat(parent.snippet.env.LS_TSMATCH, "\n")
      local replaced_content = (replacement):format(node_content)
      return vim.split(replaced_content, "\n", { trimempty = false })
    end),
  })
end

local ts_postfix_expr = function(trigger, replacement)
  return treesitter_postfix({
    trig = trigger,
    reparseBuffer = "live",
    matchTSNode = {
      query = [[
        [
          (identifier)
          (expression_statement)
        ] @prefix
      ]],
      query_lang = "typescript",
      select = "longest",
    },
  }, {
    f(function(_, parent)
      local node_content = table.concat(parent.snippet.env.LS_TSMATCH, "\n")
      local replaced_content = (replacement):format(node_content)
      return vim.split(replaced_content, "\n", { trimempty = false })
    end),
  })
end

return {
  ts_postfix_expr(".log", [[console.log(%s);]]),
  ts_postfix_expr(".pp", [[console.log(JSON.stringify(%s, undefined, 2));]]),
  ts_postfix_expr(".await", [[await (%s);]]),
  ts_postfix_expr(".return", [[return (%s);]]),

  s(
    "cons",
    fmta(
      [[
        public constructor(<>) {
          <>
        }
      ]],
      {
        i(1, "params"),
        i(2, "body"),
      }
    )
  ),

  treesitter_postfix({
    trig = ".map",
    reparseBuffer = "live",
    matchTSNode = {
      query = [[
        [
          (identifier)
          (property_identifier)
        ] @prefix
      ]],
      query_lang = "typescript",
      select = "longest",
    },
  }, {
    f(function(_, parent)
      local node_content = table.concat(parent.snippet.env.LS_TSMATCH, "\n")
      local text = ([[%s.map(%s]]):format(node_content, iteration_var_names(node_content))
      return vim.split(text, "\n", { trimempty = false })
    end),
    t([[ => ]]),
    c(1, {
      i(1),
      sn(nil, { t([[{]]), i(1), t([[}]]) }),
    }),
    -- i(2),
    t([[)]]),
  }),

  treesitter_postfix({
    trig = ".for",
    reparseBuffer = "live",
    matchTSNode = {
      query = [[
        [
          (identifier)
          (property_identifier)
        ] @prefix
      ]],
      query_lang = "typescript",
      select = "longest",
    },
  }, {
    f(function(_, parent)
      local node_content = table.concat(parent.snippet.env.LS_TSMATCH, "\n")
      local text = ("for (const %s of %s) {\n"):format(iteration_var_names(node_content), node_content)
      return vim.split(text, "\n", { trimempty = false })
    end),
    t([[  ]]),
    i(1),
    t({[[]], [[}]]}),
  }),

  s(
    { trig = "for" },
    fmta(
      [[
        for (const <> of <>) {
          <>
        }
      ]],
      { d(2, singular, { 1 }), i(1, "arr"), i(3) }
    )
  ),

  s({ trig = "ro", wordTrig = false }, {
    c(1, {
      t([[(]]),
      t([[async (]]),
    }),
    i(2, "params"),
    t([[) => ]]),
    c(3, {
      i(1),
      sn(nil, { t([[{]]), i(1), t([[}]]) }),
    }),
    i(4),
  }),

  s({ trig = "inj" }, {
    t([[@Inject(]]),
    i(1, "injection token"),
    t([[) ]]),
    c(2, {
      t([[public readonly ]]),
      t(),
    }),
    i(3, "prop"),
    t([[: ]]),
    i(4, "type"),
  }),

  s({ trig = "cprop" }, {
    c(2, {
      t([[private ]]),
      t([[public ]]),
    }),
    t([[readonly ]]),
    i(3, "prop"),
    t([[: ]]),
    i(4, "type"),
  }),

  s({ trig = "croute" }, {
    c(1, {
      t([[private ]]),
      t([[public ]]),
    }),
    t([[readonly ]]),
    t([[routing: RoutingService]]),
  }),

  s({ trig = "ccdr" }, {
    c(1, {
      t([[private ]]),
      t([[public ]]),
    }),
    t([[readonly ]]),
    t([[cdr: ChangeDetectorRef]]),
  }),

  s({ trig = "cfb" }, {
    c(1, {
      t([[private ]]),
      t([[public ]]),
    }),
    t([[readonly ]]),
    c(
      2,
      { t([[fb: UnTypedFormBuilder]]), sn(nil, { t([[fb: TypedFormBuilder<]]), i(1, "form builder type"), t([[>]]) }) }
    ),
  }),

  s({ trig = "cures" }, {
    c(1, {
      t([[private ]]),
      t([[public ]]),
    }),
    t([[readonly ]]),
    t([[uRes: UserResource]]),
  }),

  s({ trig = "cgres" }, {
    c(1, {
      t([[private ]]),
      t([[public ]]),
    }),
    t([[readonly ]]),
    t([[grRes: GroupResource]]),
  }),

  s({ trig = "cres" }, {
    c(1, {
      t([[private ]]),
      t([[public ]]),
    }),
    t([[readonly ]]),
    i(2, "shorthand"),
    t([[Res: ]]),
    i(3, "name"),
    t([[Resource]]),
  }),

  s({ trig = "oninit" }, {
    t({ [[/** @inheritdoc */]], [[public ngOnInit(): void {]], "  " }),
    i(1),
    t({ "", [[}]] }),
  }),

  s({ trig = "input" }, {
    c(1, {
      t({ [[@Input()]], "" }),
      sn(nil, { t([[@Input(']]), i(1, "input name"), t({ [[')]], "" }) }),
    }),
    t([[public ]]),
    i(2, "prop name"),
    t([[: ]]),
    i(3, "type"),
    t([[;]]),
  }),
}, {}
