((comment) @injection.content
 (#set! injection.language "comment"))

(((javascript) @injection.content)
  (#set! injection.language "javascript"))

; span(style="color: red")
(attribute
  ((attribute_name) @_name
   (#eq? @_name "style"))
  (quoted_attribute_value
   (attribute_value) @injection.content)
  (#set! injection.language "css"))

; :binding="value"
(attribute
  ((attribute_name) @_name
   (#match? @_name "^(:|v-bind|v-|\\@)"))
  (quoted_attribute_value
   (attribute_value) @injection.content)
  (#set! injection.language "javascript"))

; [state]="myState$ | async"
(attribute
  ((attribute_name) @_name
   (#lua-match? @_name "^%[.*%]"))
  (quoted_attribute_value
   (attribute_value) @injection.content)
  (#set! injection.language "javascript"))

; (myEvent)="handle($event)"
(attribute
  ((attribute_name) @_name
   (#lua-match? @_name "^%(.*%)"))
  (quoted_attribute_value
   (attribute_value) @injection.content)
  (#set! injection.language "javascript"))

; *ngIf="condition"
(attribute
  ((attribute_name) @_name
   (#lua-match? @_name "^%*.*"))
  (quoted_attribute_value
   (attribute_value) @injection.content)
  (#set! injection.language "angular"))

(escaped_string_interpolation
  ((interpolation_content) @injection.content
   (#set! injection.language "javascript")))

(tag
  (content) @injection.content
  (#set! injection.language "angular_content"))

