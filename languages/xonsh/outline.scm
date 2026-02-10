; Xonsh outline/structure

; Decorators
(decorator) @annotation

; Class definitions
(class_definition
    "class" @context
    name: (identifier) @name
    ) @item

; Function definitions
(function_definition
    "async"? @context
    "def" @context
    name: (_) @name) @item

; Xontrib statements
(xontrib_statement
    "xontrib" @context
    (xontrib_name) @name) @item

; Macro calls
(macro_call
    name: (identifier) @name) @item
