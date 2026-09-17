# MoonNginx

MoonBit codec for `nginx.conf`: lex, parse to a directive tree, dump, build, and check OSS core-module context/arity.

Behavioral reference: [nginxinc/nginx-go-crossplane](https://github.com/nginxinc/nginx-go-crossplane) (Apache-2.0). Go sources are not copied.

## Install

```text
moon add LuoYunxin1/moonnginx
```

Until the package is published, depend on this repository as a local module.

## Parse and dump

```moonbit
let cfg = unwrap_ngx(parse_conf("worker_processes 4;\n"))
let text = dump_conf(cfg)
```

## Three runnable scenarios

```text
moon run cmd/main --target wasm-gc
```

1. PARSE — `upstream` + `location` + `proxy_pass`
2. BUILD — `listen 8080` and `root /var/www`
3. VALIDATE — `listen` inside `location` is rejected

## Verify

```text
moon check --target wasm-gc --deny-warn
moon test --target wasm-gc
```

## Boundary

Does not start nginx, terminate TLS, execute Lua/OpenResty, follow `include` on disk, or speak HAProxy PROXY protocol.

## License

Apache-2.0
