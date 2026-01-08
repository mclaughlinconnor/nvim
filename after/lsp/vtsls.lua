local lsp_status = require("lsp-status")

return {
  capabilities = lsp_status.capabilities,
  settings = {
    complete_function_calls = true,
    typescript = {
      enableMoveToFileCodeAction = true,
      referencesCodeLens = { enabled = false },
      implementationsCodeLens = { enabled = false },
      format = {
        enable = false,
        insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = false, -- needed for imports to be formatted properly
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = {
          enabled = "literals",
          suppressWhenArgumentMatchesName = true,
        },
        parameterTypes = { enabled = false },
        propertyDeclarationTypes = {
          enabled = true,
          suppressWhenArgumentMatchesName = true,
        },
        variableTypes = { enabled = true },
      },
      suggest = {
        classMemberSnippets = { enabled = true },
        objectLiteralMethodSnippets = { enabled = true },
        completeFunctionCalls = true,
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsWithSnippetText = true,
        includeCompletionsForImportStatements = true,
      },
      tsserver = {
        enableRegionDiagnostics = true,
      },
      preferences = {
        preferTypeOnlyAutoImports = true,
        importModuleSpecifier = "relative",
        quoteStyle = "single",
      },
    },
  },
}
