local function same(index)
  return f(function(args)
    return args[1]
  end, { index })
end

return {
  s({ trig = "json", wordTrig = false }, {
    t([[pre {{]]),
    i(1, "prop"),
    t([[ | json }}]]),
  }),

  s({ trig = "if", wordTrig = false }, {
    t([[*ngIf=']]),
    i(1, "prop"),
    c(2, {
      t([[']]),
      sn(nil, {
        t([[; else ]]),
        i(1, [[templateName]]), -- could autocomplete templates here
        t([[']]),
      }),
    }),
  }),

  s({ trig = "tmpl", wordTrig = true }, fmta([[ng-template(<>)]], { i(1) })),

  s({ trig = "tmpln", wordTrig = false }, {
    t([[ng-template(#tpl]]),
    i(1, "name"),
    t([[)]]),
  }),

  s({ trig = "cont", wordTrig = true }, fmta([[ng-container(<>)]], { i(1) })),

  s({ trig = "for", wordTrig = false }, {
    t([[*ngFor='let ]]),
    i(1, "var name"),
    t([[ of ]]),
    i(2, "iterator"),
    t([[']]),
  }),

  s({ trig = "cls", wordTrig = true }, fmta([[[class]="<>"]], { i(1) })),
  s({ trig = "ngcls", wordTrig = true }, fmta([[[ngClass]="{<>: <>}"]], { i(1), i(2) })),
  s({ trig = "cname", wordTrig = true }, fmta([[[formControlName]="<>"]], { i(1) })), -- could definitely get for controls from the component
  s({ trig = "fg", wordTrig = true }, fmta([[[formGroup]="<>"]], { i(1) })),
  s({ trig = "fgname", wordTrig = true }, fmta([[[formGroupName]="<>"]], { i(1) })),
  s({ trig = "model", wordTrig = true }, fmta([[[ngModel]="<>"]], { i(1) })),
  s({ trig = "nsty", wordTrig = true }, fmta([[[ngStyle]="{<>: <>}"]], { i(1), i(2) })),
  s({ trig = "sw", wordTrig = true }, fmta([[[ngSwitch]="<>"]], { i(1) })),
  s({ trig = "swc", wordTrig = true }, fmta([[*ngSwitchCase="<>"]], { i(1) })),
  s({ trig = "swd", wordTrig = true }, fmta([[*ngSwitchDefault]], {})),
  s(
    { trig = "select", wordTrig = true },
    fmta(
      [[
        select([(ngModel)]="<>")
          option(*ngFor="let <> of <>" [value]="<>") {'<>'|tr}}
      ]],
      { i(1), i(2), i(3), same(2), same(2) }
    )
  ),
  s({ trig = "sty", wordTrig = true }, fmta([[[style.<>]="<>"]], { i(1), i(2) })),
  s({ trig = "tr", wordTrig = true }, fmta([[[translate]="'<>'"]], { i(1) })),
  s({ trig = "trp", wordTrig = true }, fmta([[[tr-placeholders]="{<>}"]], { i(1) })),
  s({ trig = "alertinfo", wordTrig = true }, fmta([[.alert.alert-info]])),
}, {}
