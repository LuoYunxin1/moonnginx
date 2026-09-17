# Upstream mapping

| MoonNginx | nginx-go-crossplane |
| --- | --- |
| `lex_conf` | `Lex` / `tokenize` |
| `parse_conf` | `Parse` with `SingleFile` |
| `strip_if_parens` | `prepareIfArgs` |
| `dump_conf` | `Build` / python-crossplane `dump` |
| `payload_json` | `Payload` JSON |
| `validate_core` | `analyze` context/args bitmasks (OSS subset, rewritten) |

Not mapped: include globbing, combine configs, generated nplus/app-protect tables, external Lua/njs lexers.
