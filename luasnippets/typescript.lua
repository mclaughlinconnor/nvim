return {
  postfix(".log", {
    f(function(_, parent)
      return "console.log(" .. parent.snippet.env.POSTFIX_MATCH .. ")"
    end, {}),
  }),

  postfix(".pp", {
    f(function(_, parent)
      return "console.log(JSON.stringify(" .. parent.snippet.env.POSTFIX_MATCH .. ", null, 2);"
    end, {}),
  }),

  postfix(".await", {
    f(function(_, parent)
      return "await " .. parent.snippet.env.POSTFIX_MATCH
    end, {}),
  }),

  postfix(".return", {
    f(function(_, parent)
      return "return " .. parent.snippet.env.POSTFIX_MATCH
    end, {}),
  }),

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
    c(2, {t([[fb: UnTypedFormBuilder]]), sn(nil, { t([[fb: TypedFormBuilder<]]), i(1, "form builder type"), t([[>]]) })}),
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
    t({[[public ngOnInit(): void {]], ""}),
    i(1),
    t({"", [[}]]}),
  }),

  s({ trig = "input" }, {
    c(1, {
      t({[[@Input()]], ""}),
      sn(nil, { t([[@Input(']]), i(1, "input name"), t({[[')]], ""}) }),
    }),
    t([[public ]]),
    i(2, "prop name"),
    t([[: ]]),
    i(3, "type"),
    t([[;]]),
  }),
}, {}
