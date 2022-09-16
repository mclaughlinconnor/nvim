std = "min"
files["lua/user/**/*.lua"] = {
  read_globals = {
    vim = {
      fields = {
        api = {
          other_fields = true,
        },
        cmd = {
          read_only = true,
        },
        defer_fn = {
          read_only = true,
        },
        diagnostic = {
          other_fields = true,
        },
        fn = {
          other_fields = true,
        },
        g = {
          other_fields = true,
          read_only = false,
        },
        inspect = {
          other_fields = true,
        },
        keymap = {
          other_fields = true,
        },
        lsp = {
          fields = {
            handlers = {
              other_fields = true,
              read_only = false,
            }
          },
          other_fields = true,
        },
        notify = {
          read_only = false,
        },
        o = {
          other_fields = true,
          read_only = false,
        },
        opt = {
          other_fields = true,
          read_only = false,
        },
      },
    },
  },
}

