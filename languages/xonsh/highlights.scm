; Xonsh syntax highlighting for Zed
; Uses tree-sitter-xonsh grammar (FoamScience) which extends tree-sitter-python

; ===========================================================================
; Xonsh: Environment Variables
; ===========================================================================

((env_variable
  "$" @punctuation.special
  (identifier) @variable.special) @_env
  (#set! "priority" 110))

((env_variable_braced
  "${" @punctuation.special
  "}" @punctuation.special) @_env_braced
  (#set! "priority" 110))

(env_assignment
  "=" @operator)

(env_deletion
  "del" @keyword)

; ===========================================================================
; Xonsh: Subprocess Operators
; ===========================================================================

((captured_subprocess
  "$(" @punctuation.special
  ")" @punctuation.special) @_cap_sub
  (#set! "priority" 110))

((captured_subprocess_object
  "!(" @punctuation.special
  ")" @punctuation.special) @_cap_obj
  (#set! "priority" 110))

((uncaptured_subprocess
  "$[" @punctuation.special
  "]" @punctuation.special) @_uncap_sub
  (#set! "priority" 110))

((uncaptured_subprocess_object
  "![" @punctuation.special
  "]" @punctuation.special) @_uncap_obj
  (#set! "priority" 110))

; ===========================================================================
; Xonsh: Python Evaluation in Subprocess
; ===========================================================================

((python_evaluation
  "@(" @punctuation.special
  ")" @punctuation.special) @_py_eval
  (#set! "priority" 110))

((tokenized_substitution
  "@$(" @punctuation.special
  ")" @punctuation.special) @_tok_sub
  (#set! "priority" 110))

; ===========================================================================
; Xonsh: Special @ Object
; ===========================================================================

(at_object
  "@" @punctuation.special
  "." @punctuation.delimiter
  attribute: (identifier) @property)

; ===========================================================================
; Xonsh: Glob Patterns
; ===========================================================================

((regex_glob
  "`" @punctuation.special
  (regex_glob_content) @string.regex
  "`" @punctuation.special) @_regex_glob
  (#set! "priority" 110))

((glob_pattern
  "g`" @punctuation.special
  (glob_pattern_content) @string.special
  "`" @punctuation.special) @_glob
  (#set! "priority" 110))

((formatted_glob
  "f`" @punctuation.special
  (formatted_glob_content) @string.special
  "`" @punctuation.special) @_fglob
  (#set! "priority" 110))

((glob_path
  "gp`" @punctuation.special
  (glob_path_content) @string.special
  "`" @punctuation.special) @_glob_path
  (#set! "priority" 110))

((regex_path_glob
  "rp`" @punctuation.special
  (regex_path_content) @string.regex
  "`" @punctuation.special) @_rp_glob
  (#set! "priority" 110))

((custom_function_glob
  "@" @punctuation.special
  function: (identifier) @function
  "`" @punctuation.special
  pattern: (custom_glob_content) @string.special
  "`" @punctuation.special) @_custom_glob
  (#set! "priority" 110))

; ===========================================================================
; Xonsh: Path Literals
; ===========================================================================

(path_string
  prefix: (path_prefix) @string.special.symbol)

; ===========================================================================
; Xonsh: Subprocess Modifiers
; ===========================================================================

(subprocess_modifier) @attribute

; ===========================================================================
; Xonsh: Scoped Environment Variable Command ($VAR=value cmd)
; ===========================================================================

(env_scoped_command
  env: (env_prefix
    (env_variable
      (identifier) @variable.special)
    "=" @operator))

; ===========================================================================
; Xonsh: Subprocess Body - Command and Arguments
; ===========================================================================

; First word of subprocess command is the command name
(subprocess_command
  . (subprocess_argument
      (subprocess_word) @function))

; Subsequent subprocess words are arguments
(subprocess_argument
  (subprocess_word) @string.special)

; Flags in subprocess arguments (words starting with -)
((subprocess_word) @variable.parameter
  (#match? @variable.parameter "^-"))

; ===========================================================================
; Xonsh: Subprocess Pipeline
; ===========================================================================

(subprocess_pipeline
  (subprocess_command
    . (subprocess_argument
        (subprocess_word) @function)))

; ===========================================================================
; Xonsh: Subprocess Logical (&&, ||, and, or)
; ===========================================================================

(subprocess_logical
  (subprocess_command
    . (subprocess_argument
        (subprocess_word) @function)))

; ===========================================================================
; Xonsh: Subprocess Redirections
; ===========================================================================

(redirect_target
  (subprocess_word) @string.special)

(redirect_target
  (env_variable) @variable.special)

; ===========================================================================
; Xonsh: Pipes and Operators
; ===========================================================================

(pipe_operator) @operator
(redirect_operator) @operator
(stream_merge_operator) @operator
(logical_operator) @operator

; ===========================================================================
; Xonsh: Brace Expansion
; ===========================================================================

(brace_expansion
  "{" @punctuation.special
  "}" @punctuation.special)

(brace_expansion
  "," @punctuation.delimiter)

(brace_range) @string.special
(brace_item) @string.special
(brace_literal) @string.special

; ===========================================================================
; Xonsh: Xontrib Statements
; ===========================================================================

(xontrib_statement
  "xontrib" @keyword)

(xontrib_statement
  "load" @keyword)

(xontrib_name) @property

; ===========================================================================
; Xonsh: Macro Calls
; ===========================================================================

(macro_call
  name: (identifier) @function
  "!(" @punctuation.special
  ")" @punctuation.special)

(macro_call
  argument: (macro_argument) @string.special)

; ===========================================================================
; Xonsh: Subprocess Macro (cmd! args)
; ===========================================================================

(subprocess_macro
  argument: (subprocess_macro_argument) @string.special)

; ===========================================================================
; Xonsh: Block Macro (with! Context():)
; ===========================================================================

(block_macro_statement
  "with!" @keyword)

; ===========================================================================
; Xonsh: Help Expressions
; ===========================================================================

(help_expression
  "?" @punctuation.special)

(super_help_expression
  "??" @punctuation.special)

; ===========================================================================
; Xonsh: Bare Subprocess
; ===========================================================================

(bare_subprocess
  body: (subprocess_body
    (subprocess_command
      . (subprocess_argument
          (subprocess_word) @function))))

; ===========================================================================
; Python: Comments
; ===========================================================================

(comment) @comment

; ===========================================================================
; Python: Strings
; ===========================================================================

(string) @string
(string_content) @string
(escape_sequence) @string.escape

; ===========================================================================
; Python: Docstrings
; ===========================================================================

(module
  . (expression_statement (string) @comment.doc)+)

(module
  . (comment) @comment*
  . (expression_statement (string) @comment.doc)+)

(class_definition
  body: (block . (expression_statement (string) @comment.doc)+))

(class_definition
  body: (block
    . (comment) @comment*
    . (expression_statement (string) @comment.doc)+))

(function_definition
  body: (block . (expression_statement (string) @comment.doc)+))

; ===========================================================================
; Python: Numbers
; ===========================================================================

(integer) @number
(float) @number

; ===========================================================================
; Python: Booleans and Constants
; ===========================================================================

((identifier) @boolean
  (#any-of? @boolean "True" "False"))

((identifier) @constant.builtin
  (#eq? @constant.builtin "None"))

; ===========================================================================
; Python: Identifiers
; ===========================================================================

(identifier) @variable

; Self/cls
((identifier) @variable.special
  (#any-of? @variable.special "self" "cls"))

; CamelCase for classes
((identifier) @type
  (#match? @type "^_*[A-Z][A-Za-z0-9_]*$"))

; ALL_CAPS for constants
((identifier) @constant
  (#match? @constant "^_*[A-Z][A-Z0-9_]*$"))

; Attributes
(attribute
  attribute: (identifier) @property)

; ===========================================================================
; Python: Function Definitions
; ===========================================================================

(function_definition
  name: (identifier) @function)

; Function parameters
(parameters
  (identifier) @variable.parameter)

(default_parameter
  name: (identifier) @variable.parameter)

(typed_parameter
  (identifier) @variable.parameter)

(typed_default_parameter
  name: (identifier) @variable.parameter)

; ===========================================================================
; Python: Function Calls
; ===========================================================================

(call
  function: (identifier) @function)

(call
  function: (attribute
    attribute: (identifier) @function))

; ===========================================================================
; Python: Class Definitions
; ===========================================================================

(class_definition
  name: (identifier) @type)

; ===========================================================================
; Python: Decorators
; ===========================================================================

(decorator
  "@" @attribute
  (identifier) @attribute)

(decorator
  "@" @attribute
  (call function: (identifier) @attribute))

; ===========================================================================
; Python: Imports
; ===========================================================================

(import_statement
  "import" @keyword)

(import_from_statement
  "from" @keyword
  "import" @keyword)

(aliased_import
  "as" @keyword)

(dotted_name
  (identifier) @property)

; ===========================================================================
; Python: Type Annotations
; ===========================================================================

(type (identifier) @type)
(generic_type (identifier) @type)
(type_alias_statement "type" @keyword)

; ===========================================================================
; Python: Keywords
; ===========================================================================

[
  "and"
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
  "finally"
  "for"
  "from"
  "global"
  "if"
  "import"
  "in"
  "is"
  "lambda"
  "nonlocal"
  "not"
  "or"
  "pass"
  "raise"
  "return"
  "try"
  "while"
  "with"
  "yield"
  "match"
  "case"
  "type"
] @keyword

; ===========================================================================
; Python: Operators
; ===========================================================================

[
  "+"
  "-"
  "*"
  "**"
  "/"
  "//"
  "%"
  "@"
  "|"
  "&"
  "^"
  "~"
  "<<"
  ">>"
  "<"
  ">"
  "<="
  ">="
  "=="
  "!="
  ":="
] @operator

[
  "="
  "+="
  "-="
  "*="
  "/="
  "//="
  "%="
  "**="
  "&="
  "|="
  "^="
  ">>="
  "<<="
  "@="
] @operator

; ===========================================================================
; Python: Punctuation
; ===========================================================================

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

[
  ","
  "."
  ":"
  ";"
  "->"
] @punctuation.delimiter

(interpolation
  "{" @punctuation.special
  "}" @punctuation.special) @embedded

; ===========================================================================
; Python: Builtins
; ===========================================================================

((identifier) @function
  (#any-of? @function
    "abs" "all" "any" "ascii" "bin" "bool" "breakpoint" "bytearray"
    "bytes" "callable" "chr" "classmethod" "compile" "complex"
    "delattr" "dict" "dir" "divmod" "enumerate" "eval" "exec"
    "filter" "float" "format" "frozenset" "getattr" "globals"
    "hasattr" "hash" "help" "hex" "id" "input" "int" "isinstance"
    "issubclass" "iter" "len" "list" "locals" "map" "max"
    "memoryview" "min" "next" "object" "oct" "open" "ord" "pow"
    "print" "property" "range" "repr" "reversed" "round" "set"
    "setattr" "slice" "sorted" "staticmethod" "str" "sum" "super"
    "tuple" "type" "vars" "zip" "__import__"))

; Xonsh builtins
((identifier) @function
  (#any-of? @function
    "aliases" "xontrib" "source" "xonfig" "xonsh"
    "cd" "pushd" "popd" "dirs"))

; Xonsh special identifiers
((identifier) @variable.special
  (#any-of? @variable.special
    "__xonsh__" "XSH" "aliases" "events"))

; Exception handling keywords
(raise_statement "raise" @keyword)
(try_statement "try" @keyword)
(except_clause "except" @keyword)
(finally_clause "finally" @keyword)
