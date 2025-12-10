; Xonsh syntax highlighting
; Based on Python's tree-sitter grammar since xonsh is a Python superset
;
; Note: Xonsh-specific syntax ($VAR, $(), @(), etc.) is not recognized by
; Python's tree-sitter grammar. This file handles Python syntax which covers
; the majority of xonsh code.

; Identifier naming conventions
(identifier) @variable
(attribute attribute: (identifier) @property)

; CamelCase for classes
((identifier) @type.class
  (#match? @type.class "^_*[A-Z][A-Za-z0-9_]*$"))

; ALL_CAPS for constants
((identifier) @constant
  (#match? @constant "^_*[A-Z][A-Z0-9_]*$"))

(type (identifier) @type)
(generic_type (identifier) @type)
(comment) @comment
(string) @string
(escape_sequence) @string.escape

; Type alias
(type_alias_statement "type" @keyword)

; TypeVar with constraints
(type
  (tuple (identifier) @type))

; Forward references
(type
  (string) @type)

; Function calls
(call
  function: (attribute attribute: (identifier) @function.method.call))
(call
  function: (identifier) @function.call)

; Decorators
(decorator "@" @punctuation.special)
(decorator
  "@" @punctuation.special
  [
    (identifier) @function.decorator
    (attribute attribute: (identifier) @function.decorator)
    (call function: (identifier) @function.decorator.call)
    (call (attribute attribute: (identifier) @function.decorator.call))
  ])

; Function definitions
(function_definition
  name: (identifier) @function.definition)

; isinstance/issubclass type hints
((call
  function: (identifier) @_isinstance
  arguments: (argument_list
    (_)
    (identifier) @type))
  (#eq? @_isinstance "isinstance"))

((call
  function: (identifier) @_issubclass
  arguments: (argument_list
    (identifier) @type
    (identifier) @type))
  (#eq? @_issubclass "issubclass"))

; Function parameters
(function_definition
  parameters: (parameters
  [
      (identifier) @variable.parameter
      (typed_parameter
        (identifier) @variable.parameter)
      (default_parameter
        name: (identifier) @variable.parameter)
      (typed_default_parameter
        name: (identifier) @variable.parameter)
  ]))

; Keyword arguments
(call
  arguments: (argument_list
    (keyword_argument
      name: (identifier) @function.kwargs)))

; Class definitions
(class_definition
  name: (identifier) @type.class.definition)

(class_definition
  superclasses: (argument_list
  (identifier) @type.class.inheritance))

(call
  function: (identifier) @type.class.call
  (#match? @type.class.call "^_*[A-Z][A-Za-z0-9_]*$"))

; Python builtins
((call
  function: (identifier) @function.builtin)
 (#any-of?
   @function.builtin
   "abs" "all" "any" "ascii" "bin" "bool" "breakpoint" "bytearray" "bytes"
   "callable" "chr" "classmethod" "compile" "complex" "delattr" "dict" "dir"
   "divmod" "enumerate" "eval" "exec" "filter" "float" "format" "frozenset"
   "getattr" "globals" "hasattr" "hash" "help" "hex" "id" "input" "int"
   "isinstance" "issubclass" "iter" "len" "list" "locals" "map" "max"
   "memoryview" "min" "next" "object" "oct" "open" "ord" "pow" "print"
   "property" "range" "repr" "reversed" "round" "set" "setattr" "slice"
   "sorted" "staticmethod" "str" "sum" "super" "tuple" "type" "vars" "zip"
   "__import__"))

; Xonsh-specific builtins (when used as function calls)
((call
  function: (identifier) @function.builtin)
 (#any-of?
   @function.builtin
   "aliases" "source" "execx" "evalx" "compilex"))

; Xonsh special identifiers (when they appear as plain identifiers)
((identifier) @variable.special
  (#any-of? @variable.special
    "__xonsh__" "XSH" "aliases" "events"))

; Literals
[
  (true)
  (false)
] @boolean

[
  (none)
  (ellipsis)
] @constant.builtin

[
  (integer)
  (float)
] @number

; Self/cls references
[
  (parameters (identifier) @variable.special)
  (attribute (identifier) @variable.special)
  (#any-of? @variable.special "self" "cls")
]

; Punctuation
[
  "."
  ","
  ":"
] @punctuation.delimiter

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

(interpolation
  "{" @punctuation.special
  "}" @punctuation.special) @embedded

; Docstrings
([
  (expression_statement (assignment))
  (type_alias_statement)
]
. (expression_statement (string) @string.doc)+)

(module
  .(expression_statement (string) @string.doc)+)

(class_definition
  body: (block .(expression_statement (string) @string.doc)+))

(function_definition
  "async"?
  "def"
  name: (_)
  (parameters)?
  body: (block .(expression_statement (string) @string.doc)+))

(class_definition
  body: (block
    . (comment) @comment*
    . (expression_statement (string) @string.doc)+))

(module
  . (comment) @comment*
  . (expression_statement (string) @string.doc)+)

(class_definition
  body: (block
    (expression_statement (assignment))
    . (expression_statement (string) @string.doc)+))

(class_definition
  body: (block
    (function_definition
      name: (identifier) @function.method.constructor
      (#eq? @function.method.constructor "__init__")
      body: (block
        (expression_statement (assignment))
        . (expression_statement (string) @string.doc)+))))

; Operators
[
  "-"
  "-="
  "!="
  "*"
  "**"
  "**="
  "*="
  "/"
  "//"
  "//="
  "/="
  "&"
  "%"
  "%="
  "@"
  "^"
  "+"
  "->"
  "+="
  "<"
  "<<"
  "<="
  "<>"
  "="
  ":="
  "=="
  ">"
  ">="
  ">>"
  "|"
  "~"
  "&="
  "<<="
  ">>="
  "@="
  "^="
  "|="
] @operator

; Keyword operators
[
  "and"
  "in"
  "is"
  "not"
  "or"
  "is not"
  "not in"
] @keyword.operator

; Keywords (Python + xonsh)
[
  "as"
  "assert"
  "async"
  "await"
  "break"
  "class"
  "continue"
  "def"
  "del"
  "elif"
  "else"
  "except"
  "exec"
  "finally"
  "for"
  "from"
  "global"
  "if"
  "import"
  "lambda"
  "nonlocal"
  "pass"
  "print"
  "raise"
  "return"
  "try"
  "while"
  "with"
  "yield"
  "match"
  "case"
] @keyword

; Definition keywords
[
  "async"
  "def"
  "class"
  "lambda"
] @keyword.definition

; Built-in decorators
(decorator (identifier) @attribute.builtin
  (#any-of? @attribute.builtin "classmethod" "staticmethod" "property"))

; Builtin types
[
  (call
    function: (identifier) @type.builtin)
  (type (identifier) @type.builtin)
  (generic_type (identifier) @type.builtin)
  (type
    (binary_operator
      left: (identifier) @type.builtin))
  (#any-of? @type.builtin
    "bool" "bytearray" "bytes" "complex" "dict" "float" "frozenset" "int"
    "list" "memoryview" "object" "range" "set" "slice" "str" "tuple")
]
