return {
  settings = {
    ltex = {
      language = "en-GB",
      additionalRules = {
        enablePickyRules = true,
        motherTongue = "en-GB",
      },
      disabledRules = {
        ["en-GB"] = { "OXFORD_SPELLING_NOUNS" },
      },
      checkFrequency = "save",
    },
  },
}
