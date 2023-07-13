-- {component_type: {file_type: function(component, selector) -> string}}
Generators = {}

local function the_only_type_typescript(component, selector)
  return string.format(
    [[
import {ChangeDetectionStrategy, Component} from '@angular/core';

@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  selector: 'tg-%s',
  templateUrl: './%s.component.pug',
})
export class %s {

  public constructor() {}

}
]],
    selector,
    selector,
    component
  )
end

Generators.the_only_type = {
  [".pug"] = function()
    return ""
  end,
  [".scss"] = function()
    return ""
  end,
  [".ts"] = the_only_type_typescript,
}

return Generators
