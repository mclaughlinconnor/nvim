return {
  s(
    { trig = "block", wordTrig = true },
    fmta(
      [[
        {% block <> %}
          <>
        {% endblock %}
      ]],
      { i(1), i(0) }
    )
  ),

  s(
    { trig = "for", wordTrig = true },
    fmta(
      [[
        {% for <> in <> %}
          <>
        {% endfor %}
      ]],
      { i(1), i(2), i(0) }
    )
  ),
}
