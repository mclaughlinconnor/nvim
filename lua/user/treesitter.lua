local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.pug = {
    install_info = {
      url = "~/Python/lsp/tree-sitter-pug",
      files = { "src/parser.c", "src/scanner.cc" },
      -- location = "tree-sitter-lua_neo/lua",
      revision = "8e5071f",
    },
    filetype = "pug",
    maintainers = { "@mclaughlinconnor" },
  }

configs.setup({
	ensure_installed = "all", -- one of "all" or a list of languages
  -- vimtex needs vim highlighting. the ts highlighting is nasty anyway
	ignore_install = { "phpdoc", "latex" }, -- List of parsers to ignore installing
	highlight = {
		enable = true, -- false will disable the whole extension
    -- vimtex needs vim highlighting. the ts highlighting is nasty anyway
		disable = { "css", "latex" }, -- list of language that will be disabled
	},
	autopairs = {
		enable = true,
	},
	indent = { enable = true, disable = { "python", "css" } },
  rainbow = {
    enable = true,
    disable = { },
    extended_mode = true,
    max_file_lines = nil,
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  },
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = {"BufWrite", "CursorHold"},
  },
})

