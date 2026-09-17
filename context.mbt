///|
priv struct DirSpec {
  ctxs : Array[String]
  min_args : Int
  max_args : Int
  form : Int
}

///|
fn split_ctx(s : String) -> Array[String] {
  let out : Array[String] = []
  let mut start = 0
  let mut i = 0
  while i <= s.length() {
    if i == s.length() || s[i].to_int() == 124 {
      if i > start {
        out.push(slice_text(s, start, i))
      }
      start = i + 1
    }
    i = i + 1
  }
  out
}

///|
fn spec(ctxs : String, min_args : Int, max_args : Int, form : Int) -> DirSpec {
  { ctxs: split_ctx(ctxs), min_args, max_args, form, }
}

///|
fn core_specs() -> Map[String, DirSpec] {
  let m : Map[String, DirSpec] = Map([])
  m["daemon"] = spec("main", 0, 1, 0)
  m["master_process"] = spec("main", 0, 1, 0)
  m["worker_processes"] = spec("main", 1, 1, 0)
  m["worker_rlimit_nofile"] = spec("main", 1, 1, 0)
  m["worker_cpu_affinity"] = spec("main", 1, 2, 0)
  m["worker_priority"] = spec("main", 1, 1, 0)
  m["worker_shutdown_timeout"] = spec("main", 1, 1, 0)
  m["error_log"] = spec("main|http|mail|stream|server", 1, 2, 0)
  m["pid"] = spec("main", 1, 1, 0)
  m["user"] = spec("main", 1, 2, 0)
  m["load_module"] = spec("main", 1, 1, 0)
  m["env"] = spec("main", 1, 1, 0)
  m["include"] = spec("any", 1, 1, 0)
  m["thread_pool"] = spec("main", 2, 4, 0)
  m["timer_resolution"] = spec("main", 1, 1, 0)
  m["pcre_jit"] = spec("main", 1, 1, 0)
  m["lock_file"] = spec("main", 1, 1, 0)
  m["working_directory"] = spec("main", 1, 1, 0)
  m["debug_points"] = spec("main", 1, 1, 0)
  m["ssl_engine"] = spec("main", 1, 1, 0)
  m["events"] = spec("main", 0, 0, 1)
  m["http"] = spec("main", 0, 0, 1)
  m["stream"] = spec("main", 0, 0, 1)
  m["mail"] = spec("main", 0, 0, 1)
  m["accept_mutex"] = spec("events", 1, 1, 0)
  m["accept_mutex_delay"] = spec("events", 1, 1, 0)
  m["multi_accept"] = spec("events", 1, 1, 0)
  m["use"] = spec("events", 1, 1, 0)
  m["worker_connections"] = spec("events", 1, 1, 0)
  m["worker_aio_requests"] = spec("events", 1, 1, 0)
  m["debug_connection"] = spec("events", 1, 1, 0)
  m["default_type"] = spec("http|server|location", 1, 1, 0)
  m["sendfile"] = spec("http|server|location", 1, 1, 0)
  m["tcp_nopush"] = spec("http|server|location", 1, 1, 0)
  m["tcp_nodelay"] = spec("http|server|location", 1, 1, 0)
  m["keepalive_timeout"] = spec("http|server|location", 1, 2, 0)
  m["keepalive_requests"] = spec("http|server|location|upstream", 1, 1, 0)
  m["gzip"] = spec("http|server|location|if", 1, 1, 0)
  m["gzip_types"] = spec("http|server|location", 1, 32, 0)
  m["gzip_min_length"] = spec("http|server|location", 1, 1, 0)
  m["gzip_comp_level"] = spec("http|server|location", 1, 1, 0)
  m["gzip_vary"] = spec("http|server|location", 1, 1, 0)
  m["gzip_proxied"] = spec("http|server|location", 1, 8, 0)
  m["gzip_disable"] = spec("http|server|location", 1, 1, 0)
  m["upstream"] = spec("http", 1, 1, 1)
  m["log_format"] = spec("http", 2, 32, 0)
  m["access_log"] = spec("http|server|location|if|limit_except", 1, 4, 0)
  m["resolver"] = spec("http|server|location|upstream", 1, 8, 0)
  m["resolver_timeout"] = spec("http|server|location|upstream", 1, 1, 0)
  m["client_max_body_size"] = spec("http|server|location", 1, 1, 0)
  m["client_body_buffer_size"] = spec("http|server|location", 1, 1, 0)
  m["client_header_buffer_size"] = spec("http|server", 1, 1, 0)
  m["large_client_header_buffers"] = spec("http|server", 2, 2, 0)
  m["client_body_timeout"] = spec("http|server|location", 1, 1, 0)
  m["client_header_timeout"] = spec("http|server", 1, 1, 0)
  m["send_timeout"] = spec("http|server|location", 1, 1, 0)
  m["lingering_timeout"] = spec("http|server|location", 1, 1, 0)
  m["lingering_close"] = spec("http|server|location", 1, 1, 0)
  m["reset_timedout_connection"] = spec("http|server|location", 1, 1, 0)
  m["types"] = spec("http|server|location", 0, 0, 1)
  m["charset"] = spec("http|server|location|if", 1, 1, 0)
  m["charset_types"] = spec("http|server|location", 1, 32, 0)
  m["source_charset"] = spec("http|server|location|if", 1, 1, 0)
  m["map"] = spec("http|stream", 2, 2, 1)
  m["geo"] = spec("http|stream", 1, 2, 1)
  m["split_clients"] = spec("http|stream", 2, 2, 1)
  m["proxy_cache_path"] = spec("http", 1, 16, 0)
  m["proxy_temp_path"] = spec("http|server|location", 1, 4, 0)
  m["fastcgi_temp_path"] = spec("http|server|location", 1, 4, 0)
  m["uwsgi_temp_path"] = spec("http|server|location", 1, 4, 0)
  m["scgi_temp_path"] = spec("http|server|location", 1, 4, 0)
  m["ssl_protocols"] = spec("http|server", 1, 8, 0)
  m["ssl_ciphers"] = spec("http|server", 1, 1, 0)
  m["ssl_prefer_server_ciphers"] = spec("http|server", 1, 1, 0)
  m["ssl_session_cache"] = spec("http|server", 1, 2, 0)
  m["ssl_session_timeout"] = spec("http|server", 1, 1, 0)
  m["ssl_certificate"] = spec("http|server", 1, 1, 0)
  m["ssl_certificate_key"] = spec("http|server", 1, 1, 0)
  m["ssl_verify_client"] = spec("http|server", 1, 1, 0)
  m["ssl_client_certificate"] = spec("http|server", 1, 1, 0)
  m["add_header"] = spec("http|server|location|if", 2, 3, 0)
  m["root"] = spec("http|server|location|if", 1, 1, 0)
  m["alias"] = spec("location", 1, 1, 0)
  m["index"] = spec("http|server|location", 1, 16, 0)
  m["error_page"] = spec("http|server|location|if", 2, 16, 0)
  m["try_files"] = spec("server|location", 2, 16, 0)
  m["open_file_cache"] = spec("http|server|location", 1, 2, 0)
  m["server_tokens"] = spec("http|server|location", 1, 1, 0)
  m["server_names_hash_bucket_size"] = spec("http", 1, 1, 0)
  m["server_names_hash_max_size"] = spec("http", 1, 1, 0)
  m["variables_hash_max_size"] = spec("http", 1, 1, 0)
  m["variables_hash_bucket_size"] = spec("http", 1, 1, 0)
  m["limit_req_zone"] = spec("http", 3, 4, 0)
  m["limit_conn_zone"] = spec("http", 2, 2, 0)
  m["limit_req"] = spec("http|server|location", 1, 3, 0)
  m["limit_conn"] = spec("http|server|location", 2, 2, 0)
  m["auth_basic"] = spec("http|server|location|limit_except", 1, 1, 0)
  m["auth_basic_user_file"] = spec("http|server|location|limit_except", 1, 1, 0)
  m["allow"] = spec("http|server|location|limit_except", 1, 1, 0)
  m["deny"] = spec("http|server|location|limit_except", 1, 1, 0)
  m["real_ip_header"] = spec("http|server|location", 1, 1, 0)
  m["set_real_ip_from"] = spec("http|server|location", 1, 1, 0)
  m["real_ip_recursive"] = spec("http|server|location", 1, 1, 0)
  m["listen"] = spec("server", 1, 8, 0)
  m["server_name"] = spec("server", 1, 32, 0)
  m["location"] = spec("server|location", 1, 2, 1)
  m["internal"] = spec("location", 0, 0, 0)
  m["proxy_pass"] = spec("location|if|limit_except", 1, 1, 0)
  m["proxy_set_header"] = spec("http|server|location", 2, 2, 0)
  m["proxy_hide_header"] = spec("http|server|location", 1, 1, 0)
  m["proxy_pass_header"] = spec("http|server|location", 1, 1, 0)
  m["proxy_redirect"] = spec("http|server|location", 1, 2, 0)
  m["proxy_read_timeout"] = spec("http|server|location", 1, 1, 0)
  m["proxy_connect_timeout"] = spec("http|server|location", 1, 1, 0)
  m["proxy_send_timeout"] = spec("http|server|location", 1, 1, 0)
  m["proxy_buffering"] = spec("http|server|location", 1, 1, 0)
  m["proxy_buffers"] = spec("http|server|location", 2, 2, 0)
  m["proxy_buffer_size"] = spec("http|server|location", 1, 1, 0)
  m["proxy_http_version"] = spec("http|server|location", 1, 1, 0)
  m["fastcgi_pass"] = spec("location|if", 1, 1, 0)
  m["fastcgi_index"] = spec("http|server|location", 1, 1, 0)
  m["fastcgi_param"] = spec("http|server|location", 2, 3, 0)
  m["uwsgi_pass"] = spec("location|if", 1, 1, 0)
  m["scgi_pass"] = spec("location|if", 1, 1, 0)
  m["return"] = spec("server|location|if", 1, 2, 0)
  m["rewrite"] = spec("server|location|if", 2, 3, 0)
  m["set"] = spec("server|location|if", 2, 2, 0)
  m["break"] = spec("server|location|if", 0, 0, 0)
  m["if"] = spec("server|location", 1, 16, 1)
  m["limit_except"] = spec("location", 1, 8, 1)
  m["stub_status"] = spec("server|location", 0, 1, 0)
  m["expires"] = spec("http|server|location|if", 1, 2, 0)
  m["add_trailer"] = spec("http|server|location|if", 2, 3, 0)
  m["absolute_redirect"] = spec("http|server|location", 1, 1, 0)
  m["port_in_redirect"] = spec("http|server|location", 1, 1, 0)
  m["merge_slashes"] = spec("http|server", 1, 1, 0)
  m["underscores_in_headers"] = spec("http|server", 1, 1, 0)
  m["ignore_invalid_headers"] = spec("http|server", 1, 1, 0)
  m["log_not_found"] = spec("http|server|location", 1, 1, 0)
  m["log_subrequest"] = spec("http|server|location", 1, 1, 0)
  m["recursive_error_pages"] = spec("http|server|location", 1, 1, 0)
  m["msie_padding"] = spec("http|server|location", 1, 1, 0)
  m["chunked_transfer_encoding"] = spec("http|server|location", 1, 1, 0)
  m["keepalive_disable"] = spec("http|server|location", 1, 4, 0)
  m["hash"] = spec("upstream", 1, 2, 0)
  m["ip_hash"] = spec("upstream", 0, 0, 0)
  m["keepalive"] = spec("upstream", 1, 1, 0)
  m["least_conn"] = spec("upstream", 0, 0, 0)
  m["least_time"] = spec("upstream", 1, 2, 0)
  m["queue"] = spec("upstream", 1, 2, 0)
  m["random"] = spec("upstream", 0, 2, 0)
  m["zone"] = spec("upstream", 1, 2, 0)
  m["sticky"] = spec("upstream", 1, 8, 0)
  m["protocol"] = spec("mail|server", 1, 1, 0)
  m["smtp_auth"] = spec("mail|server", 1, 8, 0)
  m["imap_auth"] = spec("mail|server", 1, 8, 0)
  m["pop3_auth"] = spec("mail|server", 1, 8, 0)
  m["smtp_capabilities"] = spec("mail|server", 1, 16, 0)
  m["xclient"] = spec("mail|server", 1, 1, 0)
  m["auth_http"] = spec("mail|server", 1, 1, 0)
  m["proxy_protocol"] = spec("stream|server", 1, 1, 0)
  m["ssl_preread"] = spec("stream|server", 1, 1, 0)
  m["proxy_timeout"] = spec("stream|server", 1, 1, 0)
  m["proxy_connect_timeout"] = spec("http|server|location|stream", 1, 1, 0)
  m["proxy_next_upstream"] = spec("http|server|location|stream|server", 1, 8, 0)
  m["proxy_next_upstream_tries"] = spec("http|server|location", 1, 1, 0)
  m["proxy_next_upstream_timeout"] = spec("http|server|location", 1, 1, 0)
  m["proxy_ssl_server_name"] = spec("http|server|location", 1, 1, 0)
  m["proxy_ssl_name"] = spec("http|server|location", 1, 1, 0)
  m["proxy_ssl_verify"] = spec("http|server|location", 1, 1, 0)
  m["fastcgi_read_timeout"] = spec("http|server|location", 1, 1, 0)
  m["fastcgi_buffers"] = spec("http|server|location", 2, 2, 0)
  m["fastcgi_buffer_size"] = spec("http|server|location", 1, 1, 0)
  m["uwsgi_param"] = spec("http|server|location", 2, 3, 0)
  m["scgi_param"] = spec("http|server|location", 2, 3, 0)
  m["client_body_in_file_only"] = spec("http|server|location", 1, 1, 0)
  m["client_body_in_single_buffer"] = spec("http|server|location", 1, 1, 0)
  m["directio"] = spec("http|server|location", 1, 1, 0)
  m["directio_alignment"] = spec("http|server|location", 1, 1, 0)
  m["output_buffers"] = spec("http|server|location", 2, 2, 0)
  m["postpone_output"] = spec("http|server|location", 1, 1, 0)
  m["read_ahead"] = spec("http|server|location", 1, 1, 0)
  m["sendfile_max_chunk"] = spec("http|server|location", 1, 1, 0)
  m["subrequest_output_buffer_size"] = spec("http|server|location", 1, 1, 0)
  m["aio"] = spec("http|server|location", 1, 2, 0)
  m["aio_write"] = spec("http|server|location", 1, 1, 0)
  m["open_file_cache_valid"] = spec("http|server|location", 1, 1, 0)
  m["open_file_cache_min_uses"] = spec("http|server|location", 1, 1, 0)
  m["open_file_cache_errors"] = spec("http|server|location", 1, 1, 0)
  m["disable_symlinks"] = spec("http|server|location", 1, 3, 0)
  m["if_modified_since"] = spec("http|server|location", 1, 1, 0)
  m["max_ranges"] = spec("http|server|location", 1, 1, 0)
  m["msie_refresh"] = spec("http|server|location", 1, 1, 0)
  m["satisfy"] = spec("http|server|location", 1, 1, 0)
  m["lingering_time"] = spec("http|server|location", 1, 1, 0)
  m["keepalive_time"] = spec("http|server|location", 1, 1, 0)
  m["http2"] = spec("http|server", 1, 1, 0)
  m["http2_max_concurrent_streams"] = spec("http|server", 1, 1, 0)
  m["http3"] = spec("http|server", 1, 1, 0)
  m["quic_retry"] = spec("http|server", 1, 1, 0)
  m["ssl_early_data"] = spec("http|server", 1, 1, 0)
  m["ssl_conf_command"] = spec("http|server", 2, 2, 0)
  m["ssl_dhparam"] = spec("http|server", 1, 1, 0)
  m["ssl_ecdh_curve"] = spec("http|server", 1, 1, 0)
  m["ssl_password_file"] = spec("http|server", 1, 1, 0)
  m["ssl_session_tickets"] = spec("http|server", 1, 1, 0)
  m["ssl_stapling"] = spec("http|server", 1, 1, 0)
  m["ssl_stapling_verify"] = spec("http|server", 1, 1, 0)
  m["ssl_trusted_certificate"] = spec("http|server", 1, 1, 0)
  m["gunzip"] = spec("http|server|location", 1, 1, 0)
  m["gunzip_buffers"] = spec("http|server|location", 2, 2, 0)
  m["gzip_static"] = spec("http|server|location", 1, 1, 0)
  m
}

///|
fn ctx_in(ctxs : Array[String], cur : String) -> Bool {
  let mut i = 0
  while i < ctxs.length() {
    if ctxs[i] == "any" || ctxs[i] == cur {
      return true
    }
    i = i + 1
  }
  false
}

///|
fn lookup_spec(name : String, ctx : String) -> DirSpec? {
  if name == "server" {
    if ctx == "http" {
      return Some(spec("http", 0, 0, 1))
    } else if ctx == "upstream" {
      return Some(spec("upstream", 1, 8, 0))
    } else {
      return None
    }
  }
  core_specs().get(name)
}

///|
pub fn known_core_directive(name : String) -> Bool {
  if name == "server" || name == "#" {
    true
  } else {
    match core_specs().get(name) {
      Some(_) => true
      None => false
    }
  }
}
