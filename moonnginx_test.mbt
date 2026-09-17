///|
test "library identity" {
  assert_eq(library_name(), "LuoYunxin1/moonnginx")
  assert_eq(syntax_profile(), "nginx-1.26-oss-core")
  assert_true(supported_blocks().length() >= 8)
  assert_true(known_core_directive("proxy_pass"))
  assert_true(known_core_directive("listen"))
}

///|
test "parse worker processes" {
  let cfg = unwrap_ngx(parse_conf("worker_processes 4;\n"))
  assert_eq(cfg.status, "ok")
  assert_eq(cfg.parsed.length(), 1)
  assert_eq(cfg.parsed[0].name, "worker_processes")
  assert_eq(cfg.parsed[0].args[0], "4")
  assert_eq(cfg.parsed[0].has_block, false)
  assert_eq(cfg.parsed[0].line, 1)
}

///|
test "parse http server location proxy_pass" {
  let src =
    #|http {
    #|    upstream app {
    #|        server 127.0.0.1:9000;
    #|    }
    #|    server {
    #|        listen 80;
    #|        server_name example.com;
    #|        location / {
    #|            proxy_pass http://app;
    #|        }
    #|    }
    #|}
    #|
  let cfg = unwrap_ngx(parse_and_validate(src))
  let ups = cfg.find_all("upstream")
  assert_eq(ups.length(), 1)
  assert_eq(ups[0].args[0], "app")
  let loc = cfg.find_all("location")
  assert_eq(loc.length(), 1)
  assert_eq(loc[0].args[0], "/")
  let pp = cfg.find_all("proxy_pass")
  assert_eq(pp.length(), 1)
  assert_eq(pp[0].args[0], "http://app")
}

///|
test "dump roundtrip keeps listen" {
  let src =
    #|events {
    #|    worker_connections 1024;
    #|}
    #|http {
    #|    server {
    #|        listen 8080;
    #|        root /var/www;
    #|    }
    #|}
    #|
  let dumped = unwrap_ngx(parse_dump(src))
  assert_true(dumped.contains("worker_connections 1024;"))
  assert_true(dumped.contains("listen 8080;"))
  assert_true(dumped.contains("root /var/www;"))
  let again = unwrap_ngx(parse_conf(dumped))
  assert_eq(again.find_all("listen").length(), 1)
}

///|
test "quoted args with spaces" {
  let cfg = unwrap_ngx(parse_conf("add_header X-Msg \"hello world\";\n"))
  assert_eq(cfg.parsed[0].args[1], "hello world")
  assert_eq(cfg.parsed[0].quoted[1], true)
  let dumped = dump_conf(cfg)
  assert_true(dumped.contains("\"hello world\""))
}

///|
test "if condition strips parentheses" {
  let src =
    #|server {
    #|    if ($request_method = POST) {
    #|        return 405;
    #|    }
    #|}
    #|
  let cfg = unwrap_ngx(parse_conf(src))
  let ifs = cfg.find_all("if")
  assert_eq(ifs.length(), 1)
  assert_eq(ifs[0].has_block, true)
  assert_true(ifs[0].args.length() >= 1)
  assert_true(!ifs[0].args[0].has_prefix("("))
  let dumped = dump_conf(cfg)
  assert_true(dumped.contains("return 405;"))
}

///|
test "comments are kept" {
  let cfg = unwrap_ngx(parse_conf("# demo\nworker_processes auto;\n"))
  assert_eq(cfg.parsed.length(), 2)
  assert_eq(cfg.parsed[0].name, "#")
  match cfg.parsed[0].comment {
    Some(c) => assert_true(c.contains("demo"))
    None => abort("missing comment")
  }
}

///|
test "include stays as ast" {
  let cfg = unwrap_ngx(parse_conf("include mime.types;\n"))
  assert_eq(cfg.parsed[0].name, "include")
  assert_eq(cfg.parsed[0].args[0], "mime.types")
  assert_eq(cfg.parsed[0].has_block, false)
}

///|
test "missing semicolon" {
  match parse_conf("worker_processes 4") {
    Ok(_) => abort("expected error")
    Err(e) =>
      assert_true(
        e.message().contains("premature") ||
        e.message().contains("unterminated"),
      )
  }
}

///|
test "unexpected rbrace" {
  match parse_conf("}\n") {
    Ok(_) => abort("expected error")
    Err(e) => assert_true(e.message().contains("unexpected"))
  }
}

///|
test "unbalanced lbrace" {
  match parse_conf("http {\nserver {\n") {
    Ok(_) => abort("expected error")
    Err(e) =>
      assert_true(
        e.message().contains("expecting }") ||
        e.message().contains("unterminated"),
      )
  }
}

///|
test "listen rejected inside location" {
  let src =
    #|http {
    #|    server {
    #|        location / {
    #|            listen 80;
    #|        }
    #|    }
    #|}
    #|
  match parse_and_validate(src) {
    Ok(_) => abort("expected constraint")
    Err(e) => {
      assert_true(e.message().contains("listen"))
      assert_true(e.message().contains("location"))
    }
  }
}

///|
test "builder listen and root" {
  let cfg = build_config([
    ngx_events([ngx_worker_connections("1024")]),
    ngx_http([
      ngx_server([
        ngx_listen("8080"),
        ngx_server_name("localhost"),
        ngx_root("/var/www"),
      ]),
    ]),
  ])
  match validate_core(cfg) {
    Ok(_) => ()
    Err(e) => abort(e.message())
  }
  let text = dump_conf(cfg)
  assert_true(text.contains("listen 8080;"))
  assert_true(text.contains("root /var/www;"))
  let json = payload_text(cfg)
  assert_true(json.contains("\"listen\""))
  assert_true(json.contains("\"line\":1"))
  assert_true(!json.contains("1.0"))
}

///|
test "query servers locations and upstream peers" {
  let src =
    #|http {
    #|    upstream app {
    #|        server 10.0.0.1:9000;
    #|        server 10.0.0.2:9000;
    #|    }
    #|    server {
    #|        listen 80;
    #|        server_name a.example;
    #|        location /api {
    #|            proxy_pass http://app;
    #|        }
    #|    }
    #|}
    #|
  let cfg = unwrap_ngx(parse_and_validate(src))
  let svs = servers_of(cfg)
  assert_eq(svs.length(), 1)
  assert_eq(listen_addrs(svs[0])[0], "80")
  match first_server_name(svs[0]) {
    Some(n) => assert_eq(n, "a.example")
    None => abort("missing server_name")
  }
  assert_eq(location_paths(svs[0])[0], "/api")
  assert_eq(proxy_backends(cfg)[0], "http://app")
  let peers = upstream_peers(cfg, "app")
  assert_eq(peers.length(), 2)
  assert_eq(includes_of(cfg).length(), 0)
  assert_true(count_directives(cfg) > 6)
  assert_true(collect_names(cfg).length() > 6)
}

///|
test "types block and rewrite" {
  let src =
    #|http {
    #|    types {
    #|        text/html html;
    #|        text/plain txt;
    #|    }
    #|    server {
    #|        listen 80;
    #|        rewrite ^/old$ /new permanent;
    #|        location / {
    #|            root /var/www;
    #|        }
    #|    }
    #|}
    #|
  let cfg = unwrap_ngx(parse_and_validate(src))
  let types = cfg.find_all("types")
  assert_eq(types.length(), 1)
  assert_eq(types[0].children.length(), 2)
  let rules = rewrite_rules(cfg)
  assert_eq(rules.length(), 1)
  assert_eq(rules[0].0, "^/old$")
}

///|
test "variable token stays together" {
  let cfg = unwrap_ngx(parse_conf("set $host_header ${host};\n"))
  assert_eq(cfg.parsed[0].name, "set")
  assert_eq(cfg.parsed[0].args[0], "$host_header")
  assert_eq(cfg.parsed[0].args[1], "${host}")
}
