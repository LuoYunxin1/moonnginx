# Architecture

1. Lexer (`lexer.mbt`) turns conf text into words, quoted strings, `;`, `{`, `}`, and comments. `${var}` stays inside a word. Brace depth is checked while lexing.
2. Parser (`parse.mbt`) reads statements. A statement is `name args ;` or `name args { stmts }`. `if` arguments lose a wrapping `(...)` pair, matching crossplane `prepareIfArgs`.
3. `include` is kept as a directive. Files are not opened.
4. Dump quotes arguments that contain spaces or were originally quoted.
5. `validate_core` walks the tree with a context stack (`main` / `events` / `http` / `server` / `location` / `upstream` / `if` / ... ) and checks arity plus block vs simple form for the OSS core table.
6. JSON follows crossplane field names: `directive`, `line`, `args`, optional `block` and `comment`. Integers use a decimal-free `repr`.
