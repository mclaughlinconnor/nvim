return {
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start({ "node", "/Users/connorveryconnect.com/.local/share/nvim/mason/packages/tsgo/node_modules/@typescript/native-preview/lib/tsgo.js", '--lsp', '--stdio' }, dispatchers)
  end,
  filetypes = {'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx'},
  root_dir = function(bufnr, on_dir)
    -- The project root is where the LSP can be started from
    -- As stated in the documentation above, this LSP supports monorepos and simple projects.
    -- We select then from the project root, which is identified by the presence of a package
    -- manager lock file.
    local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
    -- Give the root markers equal priority by wrapping them in a table
    root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers, { '.git' } }
      or vim.list_extend(root_markers, { '.git' })

    -- exclude deno
    if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' }) then
      return
    end

    -- We fallback to the current working directory if no project root is found
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

    on_dir(project_root)
  end,
  name = "tsgo",
  settings = {
    javascript = {
      referencesCodeLens = {
        enabled = true,
        showOnAllFunctions = true,
      },
      implementationsCodeLens = {
        enabled = false,
        showOnAllFunctions = false,
        showOnInterfaceMethods = false,
        showOnAllClassMethods = false,
      },
      inlayHints = {
        functionLikeReturnTypes = {enabled = true},
        parameterNames = {enabled = "all"},
        parameterTypes = {enabled = true},
        propertyDeclarationTypes = {enabled = true},
        variableTypes = {enabled = true},
      },
      ["native-preview"] = {
        customConfigFileName = "tsconfig.lsp.json",
      }

    },
    typescript = {
      referencesCodeLens = {
        enabled = true,
        showOnAllFunctions = true,
      },
      implementationsCodeLens = {
        enabled = false,
        showOnAllFunctions = false,
        showOnInterfaceMethods = false,
        showOnAllClassMethods = false,
      },
      inlayHints = {
        functionLikeReturnTypes = {enabled = true},
        parameterNames = {enabled = "all"},
        parameterTypes = {enabled = true},
        propertyDeclarationTypes = {enabled = true},
        variableTypes = {enabled = true},
      },
      format = {
        convertTabsToSpaces = true,
        indentSize = 2,
        indentStyle = 2,
        insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = false,
        insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
        semicolons = "insert",
        tabSize = 2,
      },
      suggest = {
        includeAutomaticOptionalChainCompletions = true,
        classMemberSnippets = {enabled = true},
        objectLiteralMethodSnippets = {enabled = true},
        jsdoc = {enabled = true},
      },
      ["native-preview"] = {
        customConfigFileName = "tsconfig.lsp.json",
      },
      preferences = {
        importModuleSpecifierPreference = "relative",
        preferTypeOnlyAutoImports = true,
      },
      preferGoToSourceDefinition = true,
    },
    editor = {
      codeLens = true,
      inlayHints = {enabled = true},
    },
  }
}
