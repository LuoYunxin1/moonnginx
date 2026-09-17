///|
pub fn ngx_worker_processes(n : String) -> Directive {
  dir_simple("worker_processes", [n], 1)
}

///|
pub fn ngx_error_log(path : String) -> Directive {
  dir_simple("error_log", [path], 1)
}

///|
pub fn ngx_pid(path : String) -> Directive {
  dir_simple("pid", [path], 1)
}

///|
pub fn ngx_events(children : Array[Directive]) -> Directive {
  dir_block("events", [], children, 1)
}

///|
pub fn ngx_worker_connections(n : String) -> Directive {
  dir_simple("worker_connections", [n], 1)
}

///|
pub fn ngx_http(children : Array[Directive]) -> Directive {
  dir_block("http", [], children, 1)
}

///|
pub fn ngx_server(children : Array[Directive]) -> Directive {
  dir_block("server", [], children, 1)
}

///|
pub fn ngx_listen(addr : String) -> Directive {
  dir_simple("listen", [addr], 1)
}

///|
pub fn ngx_server_name(name : String) -> Directive {
  dir_simple("server_name", [name], 1)
}

///|
pub fn ngx_root(path : String) -> Directive {
  dir_simple("root", [path], 1)
}

///|
pub fn ngx_index(names : Array[String]) -> Directive {
  dir_simple("index", names, 1)
}

///|
pub fn ngx_location(path : String, children : Array[Directive]) -> Directive {
  dir_block("location", [path], children, 1)
}

///|
pub fn ngx_location_mod(
  modifier : String,
  path : String,
  children : Array[Directive],
) -> Directive {
  dir_block("location", [modifier, path], children, 1)
}

///|
pub fn ngx_proxy_pass(url : String) -> Directive {
  dir_simple("proxy_pass", [url], 1)
}

///|
pub fn ngx_return_code(code : String) -> Directive {
  dir_simple("return", [code], 1)
}

///|
pub fn ngx_return_url(code : String, url : String) -> Directive {
  dir_simple("return", [code, url], 1)
}

///|
pub fn ngx_rewrite(regex : String, replacement : String) -> Directive {
  dir_simple("rewrite", [regex, replacement], 1)
}

///|
pub fn ngx_set(variable : String, value : String) -> Directive {
  dir_simple("set", [variable, value], 1)
}

///|
pub fn ngx_include(path : String) -> Directive {
  dir_simple("include", [path], 1)
}

///|
pub fn ngx_upstream(name : String, children : Array[Directive]) -> Directive {
  dir_block("upstream", [name], children, 1)
}

///|
pub fn ngx_upstream_server(addr : String) -> Directive {
  dir_simple("server", [addr], 1)
}

///|
pub fn ngx_access_log(path : String) -> Directive {
  dir_simple("access_log", [path], 1)
}

///|
pub fn ngx_gzip(onoff : String) -> Directive {
  dir_simple("gzip", [onoff], 1)
}

///|
pub fn ngx_sendfile(onoff : String) -> Directive {
  dir_simple("sendfile", [onoff], 1)
}

///|
pub fn ngx_keepalive_timeout(value : String) -> Directive {
  dir_simple("keepalive_timeout", [value], 1)
}

///|
pub fn ngx_client_max_body_size(value : String) -> Directive {
  dir_simple("client_max_body_size", [value], 1)
}

///|
pub fn ngx_add_header(name : String, value : String) -> Directive {
  dir_simple("add_header", [name, value], 1)
}

///|
pub fn ngx_try_files(args : Array[String]) -> Directive {
  dir_simple("try_files", args, 1)
}

///|
pub fn ngx_if(cond : Array[String], children : Array[Directive]) -> Directive {
  dir_block("if", cond, children, 1)
}

///|
pub fn ngx_allow(spec : String) -> Directive {
  dir_simple("allow", [spec], 1)
}

///|
pub fn ngx_deny(spec : String) -> Directive {
  dir_simple("deny", [spec], 1)
}

///|
pub fn build_config(dirs : Array[Directive]) -> Config {
  config_ok("nginx.conf", dirs)
}
