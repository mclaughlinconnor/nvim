return {
  s({ trig = "dbg", wordTrig = false }, {
    t([[pre {{]]),
    i(1, "prop"),
    t([[ | json }}]]),
  }),

  s({ trig = "if", wordTrig = false }, {
    t([[*ngIf=']]),
    i(1, "prop"),
    c(2, {
      t([[']]),
      t([[]]),
    }),
  }),

  s({ trig = "tmpl", wordTrig = false }, {
    t([[ng-template(#tpl]]),
    i(1, "name"),
    t([[)]]),
  }),

  s({ trig = "cont", wordTrig = false }, {
    t([[ng-container(]]),
    i(1, ""),
    t([[)]]),
  }),

  s({ trig = "for", wordTrig = false }, {
    t([[*ngFor='let ]]),
    i(1, "var name"),
    t([[ in ]]),
    i(2, "iterator"),
    t([[']]),
  }),
}, {}
