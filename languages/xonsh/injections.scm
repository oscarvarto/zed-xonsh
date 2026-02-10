; Xonsh injection queries

; Regex glob patterns use regex highlighting
(regex_glob
  (regex_glob_content) @injection.content
  (#set! injection.language "regex"))

; Regex path globs also use regex
(regex_path_glob
  (regex_path_content) @injection.content
  (#set! injection.language "regex"))
