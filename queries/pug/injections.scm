((comment) @injection.content
 (#set! injection.language "comment"))

(((javascript) @injection.content)
  (#set! injection.language "javascript"))

; :binding="value"
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
  (#set! injection.language "javascript"))

; {{ someBinding }}
(tag
  (content
   ("{" "{" ("chunk") @injection.content "}" "}"))
   (#set! injection.language "javascript"))

(escaped_string_interpolation
  ((interpolation_content) @injection.content
   (#set! injection.language "javascript")))
