///|
pub fn Directive::arg0(self : Directive) -> String? {
  if self.args.length() == 0 {
    None
  } else {
    Some(self.args[0])
  }
}

///|
pub fn Directive::child(self : Directive, name : String) -> Array[Directive] {
  let out : Array[Directive] = []
  let mut i = 0
  while i < self.children.length() {
    if self.children[i].name == name {
      out.push(self.children[i])
    }
    i = i + 1
  }
  out
}

///|
pub fn servers_of(cfg : Config) -> Array[Directive] {
  let http = cfg.find("http")
  let out : Array[Directive] = []
  let mut i = 0
  while i < http.length() {
    let kids = http[i].child("server")
    let mut j = 0
    while j < kids.length() {
      out.push(kids[j])
      j = j + 1
    }
    i = i + 1
  }
  out
}

///|
pub fn locations_of(server : Directive) -> Array[Directive] {
  server.child("location")
}

///|
pub fn listen_addrs(server : Directive) -> Array[String] {
  let ls = server.child("listen")
  let out : Array[String] = []
  let mut i = 0
  while i < ls.length() {
    match ls[i].arg0() {
      Some(a) => out.push(a)
      None => ()
    }
    i = i + 1
  }
  out
}

///|
pub fn proxy_backends(cfg : Config) -> Array[String] {
  let pps = cfg.find_all("proxy_pass")
  let out : Array[String] = []
  let mut i = 0
  while i < pps.length() {
    match pps[i].arg0() {
      Some(a) => out.push(a)
      None => ()
    }
    i = i + 1
  }
  out
}

///|
pub fn upstream_peers(cfg : Config, name : String) -> Array[String] {
  let ups = cfg.find_all("upstream")
  let out : Array[String] = []
  let mut i = 0
  while i < ups.length() {
    if ups[i].args.length() > 0 && ups[i].args[0] == name {
      let sv = ups[i].child("server")
      let mut j = 0
      while j < sv.length() {
        match sv[j].arg0() {
          Some(a) => out.push(a)
          None => ()
        }
        j = j + 1
      }
    }
    i = i + 1
  }
  out
}

///|
pub fn has_ssl(server : Directive) -> Bool {
  let certs = server.child("ssl_certificate")
  certs.length() > 0
}

///|
pub fn rewrite_rules(cfg : Config) -> Array[(String, String)] {
  let rs = cfg.find_all("rewrite")
  let out : Array[(String, String)] = []
  let mut i = 0
  while i < rs.length() {
    if rs[i].args.length() >= 2 {
      out.push((rs[i].args[0], rs[i].args[1]))
    }
    i = i + 1
  }
  out
}

///|
pub fn includes_of(cfg : Config) -> Array[String] {
  let xs = cfg.find_all("include")
  let out : Array[String] = []
  let mut i = 0
  while i < xs.length() {
    match xs[i].arg0() {
      Some(a) => out.push(a)
      None => ()
    }
    i = i + 1
  }
  out
}

///|
pub fn count_directives(cfg : Config) -> Int {
  count_list(cfg.parsed)
}

///|
fn count_list(xs : Array[Directive]) -> Int {
  let mut n = xs.length()
  let mut i = 0
  while i < xs.length() {
    if xs[i].has_block {
      n = n + count_list(xs[i].children)
    }
    i = i + 1
  }
  n
}

///|
pub fn collect_names(cfg : Config) -> Array[String] {
  let out : Array[String] = []
  collect_names_list(cfg.parsed, out)
  out
}

///|
fn collect_names_list(xs : Array[Directive], out : Array[String]) -> Unit {
  let mut i = 0
  while i < xs.length() {
    out.push(xs[i].name)
    if xs[i].has_block {
      collect_names_list(xs[i].children, out)
    }
    i = i + 1
  }
}

///|
pub fn first_server_name(server : Directive) -> String? {
  let ns = server.child("server_name")
  if ns.length() == 0 {
    None
  } else {
    ns[0].arg0()
  }
}

///|
pub fn location_paths(server : Directive) -> Array[String] {
  let locs = locations_of(server)
  let out : Array[String] = []
  let mut i = 0
  while i < locs.length() {
    if locs[i].args.length() == 1 {
      out.push(locs[i].args[0])
    } else if locs[i].args.length() >= 2 {
      out.push(locs[i].args[0] + " " + locs[i].args[1])
    }
    i = i + 1
  }
  out
}
