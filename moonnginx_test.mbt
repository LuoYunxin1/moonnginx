///|
test "library identity" {
  assert_eq(@moonnginx.library_name(), "LuoYunxin1/moonnginx")
  assert_eq(@moonnginx.syntax_profile(), "nginx-1.26-oss-core")
  assert_true(@moonnginx.supported_blocks().length() >= 8)
  assert_true(@moonnginx.known_core_directive("proxy_pass"))
  assert_true(@moonnginx.known_core_directive("listen"))
}

///|
test "parse worker processes" {
  let cfg = @moonnginx.unwrap_ngx(
    @moonnginx.parse_conf("worker_processes 4;\n"),
  )
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
  let cfg = @moonnginx.unwrap_ngx(@moonnginx.parse_and_validate(src))
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
  let dumped = @moonnginx.unwrap_ngx(@moonnginx.parse_dump(src))
  assert_true(dumped.contains("worker_connections 1024;"))
  assert_true(dumped.contains("listen 8080;"))
  assert_true(dumped.contains("root /var/www;"))
  let again = @moonnginx.unwrap_ngx(@moonnginx.parse_conf(dumped))
  assert_eq(again.find_all("listen").length(), 1)
}

///|
test "quoted args with spaces" {
  let cfg = @moonnginx.unwrap_ngx(
    @moonnginx.parse_conf("add_header X-Msg \"hello world\";\n"),
  )
  assert_eq(cfg.parsed[0].args[1], "hello world")
  assert_eq(cfg.parsed[0].quoted[1], true)
  let dumped = @moonnginx.dump_conf(cfg)
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
  let cfg = @moonnginx.unwrap_ngx(@moonnginx.parse_conf(src))
  let ifs = cfg.find_all("if")
  assert_eq(ifs.length(), 1)
  assert_eq(ifs[0].has_block, true)
  assert_true(ifs[0].args.length() >= 1)
  assert_true(!ifs[0].args[0].has_prefix("("))
  let dumped = @moonnginx.dump_conf(cfg)
  assert_true(dumped.contains("return 405;"))
}

///|
test "comments are kept" {
  let cfg = @moonnginx.unwrap_ngx(
    @moonnginx.parse_conf("# demo\nworker_processes auto;\n"),
  )
  assert_eq(cfg.parsed.length(), 2)
  assert_eq(cfg.parsed[0].name, "#")
  match cfg.parsed[0].comment {
    Some(c) => assert_true(c.contains("demo"))
    None => abort("missing comment")
  }
}

///|
test "include stays as ast" {
  let cfg = @moonnginx.unwrap_ngx(
    @moonnginx.parse_conf("include mime.types;\n"),
  )
  assert_eq(cfg.parsed[0].name, "include")
  assert_eq(cfg.parsed[0].args[0], "mime.types")
  assert_eq(cfg.parsed[0].has_block, false)
}

///|
test "missing semicolon" {
  match @moonnginx.parse_conf("worker_processes 4") {
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
  match @moonnginx.parse_conf("}\n") {
    Ok(_) => abort("expected error")
    Err(e) => assert_true(e.message().contains("unexpected"))
  }
}

///|
test "unbalanced lbrace" {
  match @moonnginx.parse_conf("http {\nserver {\n") {
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
  match @moonnginx.parse_and_validate(src) {
    Ok(_) => abort("expected constraint")
    Err(e) => {
      assert_true(e.message().contains("listen"))
      assert_true(e.message().contains("location"))
    }
  }
}

///|
test "builder listen and root" {
  let cfg = @moonnginx.build_config([
    @moonnginx.ngx_events([@moonnginx.ngx_worker_connections("1024")]),
    @moonnginx.ngx_http([
      @moonnginx.ngx_server([
        @moonnginx.ngx_listen("8080"),
        @moonnginx.ngx_server_name("localhost"),
        @moonnginx.ngx_root("/var/www"),
      ]),
    ]),
  ])
  match @moonnginx.validate_core(cfg) {
    Ok(_) => ()
    Err(e) => abort(e.message())
  }
  let text = @moonnginx.dump_conf(cfg)
  assert_true(text.contains("listen 8080;"))
  assert_true(text.contains("root /var/www;"))
  let json = @moonnginx.payload_text(cfg)
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
  let cfg = @moonnginx.unwrap_ngx(@moonnginx.parse_and_validate(src))
  let svs = @moonnginx.servers_of(cfg)
  assert_eq(svs.length(), 1)
  assert_eq(@moonnginx.listen_addrs(svs[0])[0], "80")
  match @moonnginx.first_server_name(svs[0]) {
    Some(n) => assert_eq(n, "a.example")
    None => abort("missing server_name")
  }
  assert_eq(@moonnginx.location_paths(svs[0])[0], "/api")
  assert_eq(@moonnginx.proxy_backends(cfg)[0], "http://app")
  let peers = @moonnginx.upstream_peers(cfg, "app")
  assert_eq(peers.length(), 2)
  assert_eq(@moonnginx.includes_of(cfg).length(), 0)
  assert_true(@moonnginx.count_directives(cfg) > 6)
  assert_true(@moonnginx.collect_names(cfg).length() > 6)
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
  let cfg = @moonnginx.unwrap_ngx(@moonnginx.parse_and_validate(src))
  let types = cfg.find_all("types")
  assert_eq(types.length(), 1)
  assert_eq(types[0].children.length(), 2)
  let rules = @moonnginx.rewrite_rules(cfg)
  assert_eq(rules.length(), 1)
  assert_eq(rules[0].0, "^/old$")
}

///|
test "variable token stays together" {
  let cfg = @moonnginx.unwrap_ngx(
    @moonnginx.parse_conf("set $host_header ${host};\n"),
  )
  assert_eq(cfg.parsed[0].name, "set")
  assert_eq(cfg.parsed[0].args[0], "$host_header")
  assert_eq(cfg.parsed[0].args[1], "${host}")
}

///|
test "analyze configuration structure" {
  let src =
    #|# generated fixture
    #|http {
    #|    include mime.types;
    #|    upstream app {
    #|        server 127.0.0.1:9000;
    #|    }
    #|    server {
    #|        listen 80;
    #|        location /api {
    #|            proxy_pass http://app;
    #|        }
    #|    }
    #|}
    #|
  let cfg = @moonnginx.unwrap_ngx(@moonnginx.parse_conf(src))
  let stats = @moonnginx.analyze_config(cfg)
  assert_eq(stats.directives, 8)
  assert_eq(stats.blocks, 4)
  assert_eq(stats.simple, 4)
  assert_eq(stats.comments, 1)
  assert_eq(stats.max_depth, 4)
  assert_eq(stats.servers, 2)
  assert_eq(stats.locations, 1)
  assert_eq(stats.upstreams, 1)
  assert_eq(stats.includes, 1)
  assert_eq(stats.unknown.length(), 0)
  assert_true(@moonnginx.uses_known_directives_only(cfg))
  assert_true(@moonnginx.config_summary(cfg).contains("directives=8"))
  assert_true(@moonnginx.config_summary(cfg).contains("max_depth=4"))
}

///|
test "analysis reports unique extension directives" {
  let src =
    #|http {
    #|    third_party_cache on;
    #|    server {
    #|        third_party_cache off;
    #|        vendor_toggle enabled;
    #|    }
    #|}
    #|
  let cfg = @moonnginx.unwrap_ngx(@moonnginx.parse_conf(src))
  let names = @moonnginx.unknown_directives(cfg)
  assert_eq(names.length(), 2)
  assert_eq(names[0], "third_party_cache")
  assert_eq(names[1], "vendor_toggle")
  assert_true(!@moonnginx.uses_known_directives_only(cfg))
}

///|
test "empty configuration analysis" {
  let cfg = @moonnginx.unwrap_ngx(@moonnginx.parse_conf(""))
  let stats = @moonnginx.analyze_config(cfg)
  assert_eq(stats.directives, 0)
  assert_eq(stats.max_depth, 0)
  assert_eq(stats.unknown.length(), 0)
  assert_eq(
    @moonnginx.config_summary(cfg),
    "directives=0, blocks=0, simple=0, comments=0, max_depth=0, servers=0, locations=0, upstreams=0, includes=0, unknown=0",
  )
}
