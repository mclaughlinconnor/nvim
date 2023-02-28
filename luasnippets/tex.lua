local tex = {}
tex.in_mathzone = function()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex.in_text = function()
  return not tex.in_mathzone()
end

local visual_wrap = function(trigger, start_text, end_text, opts)
  opts = opts or {}
  return ls.s(trigger, {
    ls.t({ start_text }),
    ls.d(1, function(_, snip)
      local res, env = {}, snip.env
      if vim.tbl_count(env.LS_SELECT_RAW) > 0 then
        return ls.sn(nil, {
          ls.f(function()
            for _, ele in ipairs(env.LS_SELECT_RAW) do
              table.insert(res, ele)
            end

            return res
          end, {}),
        })
      else
        return ls.sn(nil, { ls.i(1) })
      end
    end),
    ls.t({ end_text }),
  }, opts)
end

local multiline_visual_wrap = function(trigger, start_text, end_text)
  return ls.s(trigger, {
    ls.t({ start_text, "" }),
    ls.d(1, function(_, snip)
      local res, env = {}, snip.env
      if vim.tbl_count(env.LS_SELECT_RAW) > 0 then
        return ls.sn(nil, {
          ls.f(function()
            for _, ele in ipairs(env.LS_SELECT_RAW) do
              table.insert(res, "  " .. ele)
            end

            return res
          end, {}),
        })
      else
        return ls.sn(nil, { ls.t("  "), ls.i(1) })
      end
    end),
    ls.t({ "", end_text, "" }),
  })
end

local fraction = function()
  return sn(nil, {
    t([[\frac{]]),
    f(function(_, snip)
      print(vim.inspect(snip.captures))
      return snip.captures[1]
    end, {}),
    t([[}{]]),
    i(1),
    t([[} ]]),
  })
end

local function label_escape(args)
  return string.gsub(args[1][1], "%W", "_"):lower()
end

local function column_count_from_string(descr)
  return #(descr:gsub("[^clmrp]", ""))
end

local tab = function(args, snip)
  local cols = column_count_from_string(args[1][1])
  if not snip.rows then
    snip.rows = 1
  end
  local nodes = {}
  local ins_indx = 1
  for j = 1, snip.rows do
    table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t(" & "))
      table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t({ [[ \\]], "" }))
  end
  -- fix last node.
  nodes[#nodes] = t("")
  -- print(vim.inspect(nodes))
  return sn(nil, nodes)
end

return {
  s(
    { trig = "b", wordTrig = true },
    fmta(
      [[
        \begin{<>}
          <>
        \end{<>}

      ]],
      {
        i(1),
        d(2, function(_, snip)
          local res, env = {}, snip.env
          if vim.tbl_count(env.LS_SELECT_RAW) > 0 then
            return ls.sn(nil, {
              ls.f(function()
                for _, ele in ipairs(env.LS_SELECT_RAW) do
                  table.insert(res, ele)
                end

                return res
              end, {}),
            })
          else
            return sn(nil, { i(1) })
          end
        end),
        rep(1),
      }
    )
  ),

  s({ trig = "part", wordTrig = true }, {
    t([[\part{]]),
    i(1, "part name"),
    t([[}\label{prt:]]),
    f(label_escape, { 1 }),
    t({ [[}]], "", "" }),
  }),
  s({ trig = "chapter", wordTrig = true }, {
    t([[\chapter{]]),
    i(1, "chapter name"),
    t([[}\label{cha:]]),
    f(label_escape, { 1 }),
    t({ [[}]], "", "" }),
  }),
  s({ trig = "sec", wordTrig = true }, {
    t([[\section{]]),
    i(1, "section name"),
    t([[}\label{sec:]]),
    f(label_escape, { 1 }),
    t({ [[}]], "", "" }),
  }),
  s({ trig = "sec*", wordTrig = true }, {
    t([[\section*{]]),
    i(1, "section name"),
    t([[}\label{sec:]]),
    f(label_escape, { 1 }),
    t({ [[}]], "", "" }),
  }),
  s({ trig = "sub", wordTrig = true }, {
    t([[\subsection{]]),
    i(1, "subsection name"),
    t([[}\label{sub:]]),
    f(label_escape, { 1 }),
    t({ [[}]], "", "" }),
  }),
  s({ trig = "sub*", wordTrig = true }, {
    t([[\subsection*{]]),
    i(1, "subsection name"),
    t([[}\label{sub:]]),
    f(label_escape, { 1 }),
    t({ [[}]], "", "" }),
  }),
  s({ trig = "ssub", wordTrig = true }, {
    t([[\subsubsection{]]),
    i(1, "subsubsection name"),
    t([[}\label{ssub:]]),
    f(label_escape, { 1 }),
    t({ [[}]], "", "" }),
  }),
  s({ trig = "ssub*", wordTrig = true }, {
    t([[\subsubsection*{]]),
    i(1, "subsubsection name"),
    t([[}\label{ssub:]]),
    f(label_escape, { 1 }),
    t({ [[}]], "", "" }),
  }),
  s({ trig = "par", wordTrig = true }, {
    t([[\paragraph{]]),
    i(1, "paragraph name"),
    t([[}\label{par:]]),
    f(label_escape, { 1 }),
    t({ [[}]], "", "" }),
  }),
  s({ trig = "subp", wordTrig = true }, {
    t([[\subparagraph{]]),
    i(1, "subparagraph name"),
    t([[}\label{subp:]]),
    f(label_escape, { 1 }),
    t({ [[}]], "", "" }),
  }),

  s({ trig = "ab", wordTrig = true }, fmta([[\langle <> \rangle]], { i(1) }), { condition = tex.in_mathzone }),
  s({ trig = "lra", wordTrig = true }, t([[\leftrightarrow ]]), { condition = tex.in_mathzone }),
  s({ trig = "Lra", wordTrig = true }, t([[\Leftrightarrow ]]), { condition = tex.in_mathzone }),
  s({ trig = "abs", wordTrig = true }, fmta([[|<>| ]], { i(1) }), { condition = tex.in_mathzone }),
  s({ trig = "*", wordTrig = true }, t([[\cdot ]]), { condition = tex.in_mathzone }),
  s(
    { trig = "sum", wordTrig = true },
    fmta([[\sum^{<>}_{<>}]], { i(1, "upper"), i(2, "lower") }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "int", wordTrig = true },
    fmta([[\int^{<>}_{<>} ]], { i(1, "upper"), i(2, "lower") }),
    { condition = tex.in_mathzone }
  ),
  s("ls", {
    t({ [[\begin{]] }),
    c(1, {
      t("itemize"),
      t("enumerate"),
      t("description"),
      i(nil),
    }),
    t({ "}", "\t\\item " }),
    i(2),
    t({ "", "\\end{" }),
    rep(1),
    t({ "}", "" }),
    i(0),
  }),
  s(
    "tab",
    fmta(
      [[
        \begin{tabular}{<>}
          <>
        \end{tabular}
      ]],
      {
        i(1, "c"),
        d(2, tab, { 1 }, {
          user_args = {
            function(snip)
              snip.rows = snip.rows + 1
            end,
            -- don't drop below one.
            -- I have no idea why math.max didn't work
            function(snip)
              local new_value = snip.rows - 1
              if new_value < 1 then
                new_value = 1
              end
              snip.rows = new_value
            end,
          },
        }),
      }
    )
  ),
  s("nsic", t([[\si{\nano\coulomb} ]]), { condition = tex.in_mathzone }),
  s("msic", t([[\si{\micro\coulomb} ]]), { condition = tex.in_mathzone }),
  s("sic", t([[\si{\coulomb} ]]), { condition = tex.in_mathzone }),
  s("siv", t([[\si{\volt} ]]), { condition = tex.in_mathzone }),
  s("sia", t([[\si{\ampere} ]]), { condition = tex.in_mathzone }),
  s("siT", t([[\si{\tesla} ]]), { condition = tex.in_mathzone }),
  s("sideg", t([[\si{\degree} ]]), { condition = tex.in_mathzone }),
  s("simps", t([[\si{\metre\per\second} ]]), { condition = tex.in_mathzone }),
  s("sirp2s", t([[\si{\radian\per\square\second} ]]), { condition = tex.in_mathzone }),
  s("csim", t([[\si{\centi\metre} ]]), { condition = tex.in_mathzone }),
  s("siNc", t([[\si{\newton\per\coulomb} ]]), { condition = tex.in_mathzone }),
  s("siN", t([[\si{\newton} ]]), { condition = tex.in_mathzone }),
  s("simp2s", t([[\si{\metre\per\square\second} ]]), { condition = tex.in_mathzone }),
  s("sirps", t([[\si{\radian\per\second} ]]), { condition = tex.in_mathzone }),
  s("sis", t([[\si{\second} ]]), { condition = tex.in_mathzone }),
  s("siohm", t([[\si{\ohm} ]]), { condition = tex.in_mathzone }),
  s("siF", t([[\si{\farad} ]]), { condition = tex.in_mathzone }),
  s("sir", t([[\si{\radian} ]]), { condition = tex.in_mathzone }),
  s("sim", t([[\si{\metre} ]]), { condition = tex.in_mathzone }),

  parse("ks", [[\keystroke{$1} ]]),
  parse("ul", [[\underline{$1} ]]),

  parse("ita", [[\item[$1] ]]),
  parse("it", [[\item ]]),

  parse("ni", [[\noindent\n]]),

  s(
    { trig = "ceil", wordTrig = true },
    fmta([[\left\lceil <> \right\rceil ]], { i(1) }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "floor", wordTrig = true },
    fmta([[\left\lfloor <> \right\rfloor ]], { i(1) }),
    { condition = tex.in_mathzone }
  ),
}, {
  parse(
    "note",
    [[
      \begin{note}
        $1
      \end{note}
    ]]
  ),

  parse("mk", [[\($1\) ]]),
  s({ trig = "xt", wordTrig = false }, fmta([[\times 10^{<>} ]], { i(1) }), { condition = tex.in_mathzone }),
  s("pt", t([[\propto ]]), { condition = tex.in_mathzone }),
  s("dbd", fmta([[\frac{\dif <>}{\dif <>} ]], { i(1), i(2) }), { condition = tex.in_mathzone }),
  s("ibd", fmta([[\Int{<>}{<>}<> ]], { i(1), i(2), i(3) }), { condition = tex.in_mathzone }),

  parse("midnode", [[($($1)!.5!($2)$) ]]),

  parse("imint", [[\mintinline{$1}{$2} ]]),
  parse("ptcd", [[\mintinline{text}{$1} ]]),
  parse("sqlc", [[\mintinline{sql}{$1} ]]),
  parse("ccd", [[\mintinline{c}{$1} ]]),
  parse("pycd", [[\mintinline{python}{$1} ]]),
  parse("asmcd", [[\mintinline{asm}{$1} ]]),
  parse("jcd", [[\mintinline{java}{$1} ]]),

  s("trm", fmta([[\textrm{<>} ]], i(1)), { condition = tex.in_mathzone }),
  s("mrm", fmta([[\mathrm{<>} ]], i(1)), { condition = tex.in_mathzone }),

  parse(
    "eqninfo",
    [[
      \item \( $1 \) = \( $2 \) \( $3 \)
      $4
    ]]
  ),
  parse(
    "exmleqn",
    [[
      \begin{minipage}{0.49\linewidth}
          \begin{itemize}
              \item \( $1 \) = \( $2 \) \( $3 \)
              $4
          \end{itemize}
      \end{minipage}
      \hfill
      \begin{minipage}{0.49\linewidth}
          \centering
          \begin{align*}
              $5
          \end{align*}
      \end{minipage}
    ]]
  ),
  parse(
    "eqndef",
    [[
      \smallskip
      \begin{minipage}{0.4\linewidth}
          \centering
          \scalebox{2}{
            \begin{math}
              $1 = $2
            \end{math}
          }
      \end{minipage}
      \hfill
      \begin{minipage}{0.55\linewidth}
          Where:
          \begin{itemize}
            \item \( $3 \) = $4 ($5)
            $6
          \end{itemize}
      \end{minipage}

      $7
    ]]
  ),
  s(
    "eqnitem",
    fmta(
      [[
      \item \( <> \) = <> (<>)

    ]] ,
      { i(1), i(2), i(3) }
    )
  ),
  s(
    "exml",
    fmta(
      [[
      \begin{example}
          \begin{enumerate}
            \item[<>] <>
          \end{enumerate}
      \end{example}
    ]] ,
      { i(1), i(2) }
    )
  ),
  parse("subexml", [[\item[$1)] $2]]),

  s(
    "2mini",
    fmta(
      [[
      \begin{minipage}{0.45\linewidth}
          <>
      \end{minipage}
    ]] ,
      { i(1) }
    )
  ),
  s(
    "3mini",
    fmta(
      [[
      \begin{minipage}{0.30\linewidth}
          <>
      \end{minipage}
    ]] ,
      { i(1) }
    )
  ),
  s(
    "4mini",
    fmta(
      [[
      \begin{minipage}{0.20\linewidth}
          <>
      \end{minipage}
    ]] ,
      { i(1) }
    )
  ),

  s("...", t([[\ldots]]), { condition = tex.in_mathzone }),

  s({ trig = "land", wordTrig = true }, t([[\land ]]), { condition = tex.in_mathzone }),
  s({ trig = "lor", wordTrig = true }, t([[\lor ]]), { condition = tex.in_mathzone }),

  s({ trig = "impl", wordTrig = true }, t([[\implies]]), { condition = tex.in_mathzone }),

  s("iff", t([[\iff]]), { condition = tex.in_mathzone }),

  multiline_visual_wrap({ trig = "dm", wordTrig = true }, "\\[", "\\]"),

  multiline_visual_wrap({ trig = "ali", wordTrig = true }, [[\begin{align*}]], [[\end{align*}]]),

  s("//", {
    t([[\\frac{]]),
    d(1, function(_, snip)
      local res, env = {}, snip.env
      if vim.tbl_count(env.LS_SELECT_RAW) > 0 then
        return ls.sn(nil, {
          ls.f(function()
            for _, ele in ipairs(env.LS_SELECT_RAW) do
              table.insert(res, ele)
            end

            return res
          end, {}),
        })
      else
        return sn(nil, { i(1) })
      end
    end),
    t([[{]]),
    i(2),
    t([[}]]),
  }, { condition = tex.in_mathzone }),

  s(
    { trig = [[((%d*)\?([A-Za-z]+)[_^]?{%d+})/]], regTrig = true },
    d(1, fraction, {}),
    { condition = tex.in_mathzone }
  ), -- 2\sigma_{2}
  s({ trig = [[((%d*)\?([A-Za-z]+)[_^]?%d+)/]], regTrig = true }, d(1, fraction, {}), { condition = tex.in_mathzone }), -- 2\sigma_2
  s({ trig = [[(\?([A-Za-z]+)[_^]%d)/]], regTrig = true }, d(1, fraction, {}), { condition = tex.in_mathzone }), -- \sigma_2
  s({ trig = [[(\?([A-Za-z]+)[_^]{%d+})/]], regTrig = true }, d(1, fraction, {}), { condition = tex.in_mathzone }), -- \sigma_{2}
  s({ trig = [[(\?[A-Za-z]+)/]], regTrig = true }, d(1, fraction, {}), { condition = tex.in_mathzone }), -- \sigma
  s({ trig = "(%d+)/", regTrig = true }, d(1, fraction, {}), { condition = tex.in_mathzone }), -- 2

  s(
    { trig = "==", wordTrig = true },
    fmta(
      [[
        &= <> \\\\

      ]],
      { i(1) }
    ),
    { condition = tex.in_mathzone }
  ),

  s({ trig = "e=", wordTrig = true }, t([[&= ]])),

  s({ trig = "neq", wordTrig = true }, t([[\neq ]]), { condition = tex.in_mathzone }),

  visual_wrap("()", [[\left( ]], [[ \right) ]], { condition = tex.in_mathzone }),
  visual_wrap("lr", [[\left( ]], [[ \right) ]], { condition = tex.in_mathzone }),
  visual_wrap("lr(", [[\left( ]], [[ \right) ]], { condition = tex.in_mathzone }),
  visual_wrap("lr|", [[\left| ]], [[ \right| ]], { condition = tex.in_mathzone }),
  visual_wrap("lr{", [[\left\\{ ]], [[ \right\\} ]], { condition = tex.in_mathzone }),
  visual_wrap("lrb", [[\left\\{ ]], [[ \right\\} ]], { condition = tex.in_mathzone }),
  visual_wrap("lr[", [[\left[ ]], [[ \right]  ]], { condition = tex.in_mathzone }),
  visual_wrap("lra", [[\left<]], [[ \right>]], { condition = tex.in_mathzone }),

  visual_wrap("sqr", [[\sqrt{]], [[} ]], { condition = tex.in_mathzone }),

  s({ trig = "sr", wordTrig = false }, t([[^2]]), { condition = tex.in_mathzone }),
  s({ trig = "cb", wordTrig = false }, t([[^3]]), { condition = tex.in_mathzone }),
  s({ trig = "td", wordTrig = false }, fmta([[^{<>} ]], { i(1) }), { condition = tex.in_mathzone }),
  s({ trig = "__", wordTrig = false }, fmta([[_{<>} ]], { i(1) }), { condition = tex.in_mathzone }),

  parse("ooo", [[\infty]]),

  parse("xnn", [[x_{n}]]),
  parse("ynn", [[y_{n}]]),

  s({ trig = "xx", wordTrig = false }, t([[\times ]]), { condition = tex.in_mathzone }),
  s({ trig = "**", wordTrig = false }, t([[\cdot ]]), { condition = tex.in_mathzone }),
  s("norm", fmta([[\|<>\| ]], { i(1) }), { condition = tex.in_mathzone }),
  s({ trig = "invs", wordTrig = false }, t([[^{-1} ]]), { condition = tex.in_mathzone }),
  s({ trig = "||", wordTrig = false }, t([[ \mid ]]), { condition = tex.in_mathzone }),

  s("EE", t([[\exists ]]), { condition = tex.in_mathzone }),
  s("AA", t([[\forall ]]), { condition = tex.in_mathzone }),
  s("cc", t([[\subset ]]), { condition = tex.in_mathzone }),
  s("nquiv", t([[\not\equiv ]]), { condition = tex.in_mathzone }),
  s("notin", t([[\not\in ]]), { condition = tex.in_mathzone }),
  s("inn", t([[\in ]]), { condition = tex.in_mathzone }),
  s("NN", t([[\N ]]), { condition = tex.in_mathzone }),
  s("Nn", t([[\cap ]]), { condition = tex.in_mathzone }),
  s("UU", t([[\cup ]]), { condition = tex.in_mathzone }),
  s("OO", t([[\O ]]), { condition = tex.in_mathzone }),
  s("RR", t([[\R ]]), { condition = tex.in_mathzone }),
  s("QQ", t([[\Q ]]), { condition = tex.in_mathzone }),
  s("ZZ", t([[\Z ]]), { condition = tex.in_mathzone }),
  s("HH", t([[\mathbb{H} ]]), { condition = tex.in_mathzone }),
  s("Uu", t([[\mathbb{U} ]]), { condition = tex.in_mathzone }),
  s("DD", t([[\mathbb{D} ]]), { condition = tex.in_mathzone }),

  s("equiv", t([[\equiv ]]), { condition = tex.in_mathzone }),
  s("neg", t([[\neg ]]), { condition = tex.in_mathzone }),

  s("tt", fmta([[\text{<>} ]], { i(1) }), { condition = tex.in_mathzone }),
  s("bf", fmta([[\textbf{<>} ]], { i(1) })),

  s("bar", fmta([[\overline{<>} ]], { i(1) })),
  s("hat", fmta([[\hat{<>} ]], { i(1) })),

  visual_wrap({ trig = "emp", wordTrig = true }, [[\emph{]], [[} ]]),
}

-- todo better sub/super script
-- also spaces after exiting math mode optionally
