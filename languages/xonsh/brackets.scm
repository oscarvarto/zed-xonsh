; Xonsh bracket matching
; Standard Python brackets
("(" @open ")" @close)
("[" @open "]" @close)
("{" @open "}" @close)

; Xonsh subprocess operators
("$(" @open ")" @close)
("$[" @open "]" @close)
("!(" @open ")" @close)
("![" @open "]" @close)
("@(" @open ")" @close)
("@$(" @open ")" @close)

; Strings (exclude from rainbow)
(((string_start) @open (string_end) @close) (#set! rainbow.exclude))
