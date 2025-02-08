local events =  require("luasnip.util.events")

local injectCallbacks = {
  callbacks = {
    [-1] = {
      [events.pre_expand] = function()
        vim.lsp.buf.execute_command({
          command = "ts_inspector/addImport",
          arguments = {
            vim.uri_from_bufnr(0),
            "@angular/core",
            {},
            {"inject"},
          },
        })
      end
    }
  }
}

local function same(index)
  return f(function(args)
    return args[1]
  end, { index })
end

local function component_name(index, prefix)
  return f(function(args)
    local n = args[1][1]
    if prefix then
      return { "tg-" .. (n):gsub(" ", "-"):gsub("([a-z])([A-Z])", "%1-%2"):lower() }
    else
      return { (n):gsub(" ", "-"):gsub("([a-z])([A-Z])", "%1-%2"):lower() }
    end
  end, { index })
end

local function lowercase(index)
  return f(function(args)
    local n = args[1][1]
    return string.lower(n)
  end, { index })
end

local function lowercase_first(index)
  return f(function(args)
    local n = args[1][1]
    return (n:gsub("^%l", string.upper))
  end, { index })
end

---Attempts to (in decreasing order of presedence):
-- - Convert a plural noun into a singular noun
-- - Return the first letter of the word
-- - Return "item" as a fallback
local function iteration_var_names(last_word)
  -- initialize with fallback
  local singular_word = "item"

  if string.match(last_word, ".s$") then
    -- assume the given input is plural if it ends in s. This isn't always
    -- perfect, but it's pretty good
    singular_word = string.gsub(last_word, "s$", "", 1)
  elseif string.match(last_word, "^_?%w.+") then
    -- include an underscore in the match so that inputs like '_name' will
    -- become '_n' and not just '_'
    singular_word = string.match(last_word, "^_?.")
  end

  return singular_word
end

local function singular(input)
  local plural_word = input[1][1]
  local last_word = string.match(plural_word, "[_%w]*$")

  -- initialize with fallback
  local singular_word = iteration_var_names(last_word)

  return s("{}", i(1, singular_word))
end

local ts_postfix_term = function(trigger, replacement)
  return treesitter_postfix({
    trig = trigger,
    reparseBuffer = "live",
    matchTSNode = {
      query = [[
        [
          (identifier)
          (property_identifier)
        ] @prefix
      ]],
      query_lang = "typescript",
      select = "longest",
    },
  }, {
    f(function(_, parent)
      local node_content = table.concat(parent.snippet.env.LS_TSMATCH, "\n")
      local replaced_content = (replacement):format(node_content)
      return vim.split(replaced_content, "\n", { trimempty = false })
    end),
  })
end

local ts_postfix_expr = function(trigger, replacement)
  return treesitter_postfix({
    trig = trigger,
    reparseBuffer = "live",
    matchTSNode = {
      query = [[
        [
          (identifier)
          (expression_statement)
        ] @prefix
      ]],
      query_lang = "typescript",
      select = "longest",
    },
  }, {
    f(function(_, parent)
      local node_content = table.concat(parent.snippet.env.LS_TSMATCH, "\n")
      local replaced_content = (replacement):format(node_content)
      return vim.split(replaced_content, "\n", { trimempty = false })
    end),
  })
end

return {
  ts_postfix_expr(".log", [[console.log(%s);]]),
  ts_postfix_expr(".pp", [[console.log(JSON.stringify(%s, undefined, 2));]]),
  ts_postfix_expr(".await", [[await (%s);]]),
  ts_postfix_expr(".ret", [[return (%s);]]),

  s(
    "cons",
    fmta(
      [[
        public constructor(<>) {
          <>
        }
      ]],
      {
        i(1),
        i(2),
      }
    )
  ),

  treesitter_postfix({
    trig = ".map",
    reparseBuffer = "live",
    matchTSNode = {
      query = [[
        [
          (identifier)
          (property_identifier)
        ] @prefix
      ]],
      query_lang = "typescript",
      select = "longest",
    },
  }, {
    f(function(_, parent)
      local node_content = table.concat(parent.snippet.env.LS_TSMATCH, "\n")
      local text = ([[%s.map(%s]]):format(node_content, iteration_var_names(node_content))
      return vim.split(text, "\n", { trimempty = false })
    end),
    t([[ => ]]),
    c(1, {
      i(1),
      sn(nil, { t([[{]]), i(1), t([[}]]) }),
    }),
    -- i(2),
    t([[);]]),
  }),

  treesitter_postfix({
    trig = ".for",
    reparseBuffer = "live",
    matchTSNode = {
      query = [[
        [
          (identifier)
          (property_identifier)
        ] @prefix
      ]],
      query_lang = "typescript",
      select = "longest",
    },
  }, {
    f(function(_, parent)
      local node_content = table.concat(parent.snippet.env.LS_TSMATCH, "\n")
      local text = ("for (const %s of %s) {\n"):format(iteration_var_names(node_content), node_content)
      return vim.split(text, "\n", { trimempty = false })
    end),
    t([[  ]]),
    i(1),
    t({ [[]], [[}]] }),
  }),

  s(
    { trig = "for" },
    fmta(
      [[
        for (const <> of <>) {
          <>
        }
      ]],
      { d(2, singular, { 1 }), i(1, "arr"), i(3) }
    )
  ),

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
    c(1, {
      t([[private ]]),
      t([[public ]]),
    }),
    t([[readonly ]]),
    i(2, "prop"),
    t([[ = inject(]]),
    i(3, "injection token"),
    t([[);]]),
  },
  injectCallbacks
  ),

  s({ trig = "prop" }, {
    c(1, {
      t([[private]]),
      t([[public]]),
    }),
    c(2, {
      t([[ ]]),
      t([[ readonly ]]),
    }),
    i(3, "prop"),
    t([[: ]]),
    i(4, "type"),
    t([[;]]),
  }),

  s({ trig = "injroute" }, {
    c(1, { t([[private ]]), t([[public ]]) }),
    t([[readonly ]]),
    t([[routing = inject(RoutingService);]]),
  },
  injectCallbacks
  ),

  s({ trig = "injcdr" }, {
    c(1, { t([[private ]]), t([[public ]]) }),
    t([[readonly ]]),
    t([[cdr = inject(ChangeDetectorRef);]]),
  },
  injectCallbacks
  ),

  s({ trig = "injfb" }, {
    c(1, { t([[private ]]), t([[public ]]) }),
    t([[readonly ]]),
    c(2, { t([[fb = inject(UnTypedFormBuilder)]]), t([[fb = inject(TypedFormBuilder)]]) }),
    t([[;]]),
  },
  injectCallbacks
  ),

  s({ trig = "injures" }, {
    c(1, { t([[private ]]), t([[public ]]) }),
    t([[readonly ]]),
    t([[uRes = inject(UserResource);]]),
  },
  injectCallbacks
  ),

  s({ trig = "injgres" }, {
    c(1, { t([[private ]]), t([[public ]]) }),
    t([[readonly ]]),
    t([[grRes = inject(GroupResource);]]),
  },
  injectCallbacks
  ),

  s({ trig = "injres" }, {
    c(1, {
      t([[private ]]),
      t([[public ]]),
    }),
    t([[readonly ]]),
    i(2, "shorthand"),
    t([[Res = inject(]]),
    i(3, "name"),
    t([[Resource);]]),
  },
  injectCallbacks
  ),

  s({ trig = "oninit" }, {
    t({ [[/** @inheritdoc */]], [[public ngOnInit(): void {]], "  " }),
    i(1),
    t({ "", [[}]] }),
  }),

  s({ trig = "input" }, {
    c(1, {
      t({ [[@Input()]], "" }),
      sn(nil, { t([[@Input(']]), i(1, "input name"), t({ [[')]], "" }) }),
    }),
    t([[public ]]),
    i(2, "prop name"),
    t([[: ]]),
    i(3, "type"),
    t([[;]]),
  },
  {
    callbacks = {
      [-1] = {
        [events.pre_expand] = function()
          vim.lsp.buf.execute_command({
            command = "ts_inspector/addImport",
            arguments = {
              vim.uri_from_bufnr(0),
              "@angular/core",
                {},
              {"Input"},
            },
          })
        end
      }
    }
  }),

  s(
    { trig = "output", wordTrig = true },
    fmt(
      [[
        @Output('{}')
        public readonly {}$ = new EventEmitter<{}>();
      ]],
      { i(1), same(1), i(2, "type") }
    ),
    {
      callbacks = {
        [-1] = {
          [events.pre_expand] = function()
            vim.lsp.buf.execute_command({
              command = "ts_inspector/addImport",
              arguments = {
                vim.uri_from_bufnr(0),
                "@angular/core",
                {},
                {"EventEmitter", "Output"},
              },
            })
          end
        }
      }
    }
  ),

  s(
    { trig = "comp", wordTrig = true },
    fmta(
      [[
        import {ChangeDetectionStrategy, Component} from '@angular/core';

        @Component({
          changeDetection: ChangeDetectionStrategy.OnPush,
          imports: [
            GlobalModule,
          ],
          selector: '<>',
          standalone: true,
          templateUrl: './<>.component.pug',
        })
        export class <>Component {
          <>
        }
      ]],
      { component_name(1, true), component_name(1), i(1), i(2) }
    )
  ),

  s(
    { trig = "dir", wordTrig = true },
    fmta(
      [[
        import {Directive} from '@angular/core';

        @Directive({ selector: '[<>]' })
        export class <>Directive {
          constructor() { }
        }
      ]],
      { component_name(1, false), i(1) }
    )
  ),

  s(
    { trig = "injectable", wordTrig = true },
    fmta(
      [[
        @Injectable<><>
      ]],
      { c(1, { t([[({providedIn: 'root'})]]), t([[()]]) }), i(2) }
    )
  ),

  s(
    { trig = "service", wordTrig = true },
    fmta(
      [[
        import {Injectable} from '@angular/core';

        @Injectable<>
        export class <>Service {
          constructor() { }

          <>
        }
      ]],
      { c(1, { t([[({providedIn: 'root'})]]), t([[()]]) }), i(2), i(3) }
    )
  ),

  s(
    { trig = "module", wordTrig = true },
    fmta(
      [[
        import {NgModule} from '@angular/core';
        import {<>Component} from './<>.component';

        @NgModule({
          imports: [
            GlobalModule,
          ],
          exports: [],
          declarations: [<>Component],
          providers: [],
        })
        export class <>Module { }
      ]],
      { same(1), component_name(1, false), same(1), i(1) }
    )
  ),

  s(
    { trig = "pipe", wordTrig = true },
    fmta(
      [[
        import {Pipe, PipeTransform} from '@angular/core';

        @Pipe({
          name: '<>'
        })
        export class <>Pipe implements PipeTransform {
          transform(value: <>): <> {
            <>
          }
        }
      ]],
      { lowercase_first(1), i(1), i(2, "type"), i(3, "return"), i(4) }
    )
  ),

  s(
    { trig = "model", wordTrig = true },
    fmta(
      [[
        import {model, Schema} from 'mongoose';
        import type {MongooseDoc, MongooseModel, MongooseSchemaDef} from '../lib/mongoose/MongooseUtil';

        interface <>InterfaceBase {
        }

        export interface <>Interface extends MongooseDoc<<<>InterfaceBase>> { }

        const definition: MongooseSchemaDef<<<>InterfaceBase>> = {
        };

        const schema = new Schema<<<>Interface>>(definition, {
          collection: '<>',
          timestamps: true,
        });

        export const <>Model = model<<<>Interface, MongooseModel<<<>Interface>>>>('<>', schema);
      ]],
      {
        i(1),
        lowercase_first(1),
        lowercase_first(1),
        lowercase_first(1),
        lowercase_first(1),
        lowercase(1),
        same(1),
        lowercase_first(1),
        lowercase_first(1),
        lowercase_first(1),
      }
    )
  ),

  s({ trig = "apa", wordTrig = true }, fmta([[await Promise.all(<>);]], { i(1) })),
  s({ trig = "pa", wordTrig = true }, fmta([[Promise.all(<>)]], { i(1) })),
  s({ trig = "la", wordTrig = true }, fmta([[let <> = await <>;]], { i(1), i(2) })),
  s({ trig = "ca", wordTrig = true }, fmta([[const <> = await <>;]], { i(1), i(2) })),
  s({ trig = "ov", wordTrig = true }, fmta([[Object.values(<>)]], { i(1) })),

  s(
    { trig = "controller", wordTrig = true },
    fmta(
      [[
        import type {Request, Response} from '../../definitions/sails';
        import {<>Model} from '../../models/<>';

        export async function destroy(req: Request, res: Response) {
          return await <>Model
            .deleteOne({_id: req.params.id})
            .then(res.ok)
            .catch(res.negotiate);
        }

        export async function find(_req: Request, res: Response) {
          return await <>Model
            .find({})
            .then(res.ok)
            .catch(res.negotiate);
        }

        export async function findOne(req: Request, res: Response) {
          return await <>Model
            .find({_id: req.params.id})
            .then(res.ok)
            .catch(res.negotiate);
        }

        export async function update(req: Request, res: Response) {
          return await <>Model
            .updateOne({_id: req.params.id}, req.body)
            .then(res.ok)
            .catch(res.negotiate);
        }
      ]],
      { i(1), same(1), same(1), same(1), same(1), same(1) }
    )
  ),

  s(
    { trig = "endpoints", wordTrig = true },
    fmta(
      [[
        'DELETE /api/v1/<>/:id': {
          controller: '<>Controller',
          action: 'destroy'
        },

        'GET /api/v1/<>': {
          controller: '<>Controller',
          action: 'find'
        },

        'GET /api/v1/<>/:id': {
          controller: '<>Controller',
          action: 'findOne',
        },

        'POST /api/v1/<>/:id': {
          controller: '<>Controller',
          action: 'update',
        },
      ]],
      { lowercase(1), i(1), lowercase(1), same(1), lowercase(1), same(1), lowercase(1), same(1) }
    )
  ),

  s(
    { trig = ".alert", wordTrig = true },
    fmta(
      [[
        .pipe(
          tap({
            error: err =>> {
              this.alertSvc.negotiate(err, {defaultMessage: {key: '<>Failure', <>}});
            },
            next: () =>> {
              this.alertSvc.alertSuccess({key: '<>Success', <>});
            },
          })
        )
        .subscribe(finaliseObserver(() =>> {
          this.cdr.markForCheck();
        }));
      ]],
      { i(1), c(2, {t([[ns]]), sn(nil, {t([[ns: ]]), i(1)})}), same(1), same(2)}
    ),
    {
      callbacks = {
        [-1] = {
          [events.pre_expand] = function()
            vim.lsp.buf.execute_command({
              command = "ts_inspector/addImport",
              arguments = {
                vim.uri_from_bufnr(0),
                "@aloreljs/rxutils",
                {},
                {"finaliseObserver"},
              },
            })
          end
        }
      }
    }
  ),

  s(
    { trig = "vref", wordTrig = true },
    fmta(
      [[
        import type {TgResourceResponse, WithResponseClass} from '@veryconnect/tg-resource';
        import {TgResourceVirtualRef} from '@veryconnect/tg-resource';
        import type {TgResourceDoc} from '../../tg-resource/tg-resource-util-types';

        interface Overrides {
        }

        export type <>Frontend = TgResourceDoc<<Omit<<<>InterfaceBase, keyof Overrides>>>> & Overrides;

        interface <>VirtualRefResponse extends <>Frontend {
        }

        interface <>VirtualRefResponse
          extends TgResourceResponse<<<>Frontend, TgResourceVirtualRef<<<>Frontend>>>> {
        }

        const <>VirtualRef = TgResourceVirtualRef
          .inline<<<>Frontend, WithResponseClass<<<>VirtualRefResponse>>>>({
            name: '<>VirtualRef',
            // references: {
            //  user: TgResourceName.USER,
            // },
            // fieldSerialisers: {
            //   created_time: DateSerialiser,
            // },
          });

        export {<>VirtualRefResponse, <>VirtualRef};
      ]],
      { i(1), same(1), same(1), same(1), same(1), same(1), same(1), same(1), same(1), same(1), same(1), same(1), same(1) }
    )
  ),
}, {}
