# MoonNginx

MoonBit codec for `nginx.conf`: lex, parse to a directive tree, dump, build, query, and check OSS core-module context/arity.

Behavioral reference: [nginxinc/nginx-go-crossplane](https://github.com/nginxinc/nginx-go-crossplane) (Apache-2.0). Go sources are not copied; see [THIRD_PARTY.md](THIRD_PARTY.md).

## What it provides

- A loss-aware lexer and nested directive-tree parser for common `nginx.conf` syntax.
- Stable dumping with quoting, comments, nested blocks, and variable tokens preserved.
- Typed builders for common `events`, `http`, `server`, `location`, and `upstream` structures.
- Core-context and argument validation for the supported OSS directive profile.
- Queries for servers, locations, upstream peers, includes, proxy backends, and rewrite rules.
- Structural analysis with directive counts, nesting depth, and extension-directive discovery.
- Crossplane-style JSON payload output for tooling and migration workflows.

The package is a configuration codec and static validator. It does not start nginx or execute configuration directives.

## Install

The package is published as `LuoYunxin1/moonnginx@0.1.0` on MoonCakes:

```text
moon add LuoYunxin1/moonnginx
```

For a checked-out development copy, run commands from the repository root. MoonBit 0.10.14 or newer is required for acceptance and CI.

## Minimal use

```moonbit
let cfg = unwrap_ngx(parse_and_validate("worker_processes 4;\\n"))
let text = dump_conf(cfg)
println(text)
```

`parse_and_validate` returns a structured `NgxError` instead of silently accepting an invalid core-module context. Use `parse_conf` when you need parsing without policy validation.

## Three runnable scenarios

The repository includes a runnable executable covering three representative workflows:

```text
moon run cmd/main --target wasm-gc
```

1. **PARSE** — parse an `upstream` and a `server/location` containing `proxy_pass`, then dump the tree.
2. **BUILD** — construct an `http`/`server` configuration with `listen 8080` and `root /var/www`.
3. **VALIDATE** — reject `listen` nested inside `location` and print the diagnostic.

The demo is intentionally independent of a locally installed nginx process and is therefore reproducible on the MoonBit WebAssembly target.

## Verify locally

```text
moon version --all
moon info
moon fmt
moon check --target wasm-gc --deny-warn
moon test --target wasm-gc --deny-warn
moon build --target wasm-gc --deny-warn
moon run cmd/main --target wasm-gc
```

The test suite covers lexing, comments and quoting, nested parsing, round-trip dumping, builders, queries, JSON payloads, validation errors, and whitebox token behavior. CI runs check, build, test, and the runnable demo on every push and pull request.

## Boundary

MoonNginx does not start nginx, terminate TLS, execute Lua/OpenResty, follow `include` files on disk, or speak the HAProxy PROXY protocol. Those responsibilities remain with the caller or a runtime integration.

## License

Apache-2.0. See [LICENSE](LICENSE).
