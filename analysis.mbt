///|
/// Structural metrics for a parsed nginx configuration.
pub(all) struct ConfigStats {
  mut directives : Int
  mut blocks : Int
  mut simple : Int
  mut comments : Int
  mut max_depth : Int
  mut servers : Int
  mut locations : Int
  mut upstreams : Int
  mut includes : Int
  unknown : Array[String]
} derive(Eq, Debug)

///|
fn empty_stats() -> ConfigStats {
  {
    directives: 0,
    blocks: 0,
    simple: 0,
    comments: 0,
    max_depth: 0,
    servers: 0,
    locations: 0,
    upstreams: 0,
    includes: 0,
    unknown: [],
  }
}

///|
fn push_unique_name(names : Array[String], name : String) -> Unit {
  let mut i = 0
  while i < names.length() {
    if names[i] == name {
      return
    }
    i = i + 1
  }
  names.push(name)
}

///|
fn merge_unknown_names(into : Array[String], from : Array[String]) -> Unit {
  let mut i = 0
  while i < from.length() {
    push_unique_name(into, from[i])
    i = i + 1
  }
}

///|
fn max_int(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn analyze_list(xs : Array[Directive], depth : Int) -> ConfigStats {
  let out = empty_stats()
  let mut i = 0
  while i < xs.length() {
    let d = xs[i]
    if d.name == "#" {
      out.comments = out.comments + 1
    } else {
      out.directives = out.directives + 1
      out.max_depth = max_int(out.max_depth, depth)
      if d.has_block {
        out.blocks = out.blocks + 1
      } else {
        out.simple = out.simple + 1
      }
      if d.name == "server" {
        out.servers = out.servers + 1
      } else if d.name == "location" {
        out.locations = out.locations + 1
      } else if d.name == "upstream" {
        out.upstreams = out.upstreams + 1
      } else if d.name == "include" {
        out.includes = out.includes + 1
      }
      if !known_core_directive(d.name) {
        push_unique_name(out.unknown, d.name)
      }
      if d.has_block {
        let child = analyze_list(d.children, depth + 1)
        out.directives = out.directives + child.directives
        out.blocks = out.blocks + child.blocks
        out.simple = out.simple + child.simple
        out.comments = out.comments + child.comments
        out.max_depth = max_int(out.max_depth, child.max_depth)
        out.servers = out.servers + child.servers
        out.locations = out.locations + child.locations
        out.upstreams = out.upstreams + child.upstreams
        out.includes = out.includes + child.includes
        merge_unknown_names(out.unknown, child.unknown)
      }
    }
    i = i + 1
  }
  out
}

///|
/// Analyze the directive tree without executing nginx or resolving includes.
pub fn analyze_config(cfg : Config) -> ConfigStats {
  analyze_list(cfg.parsed, 1)
}

///|
/// Return unique directive names that are outside the built-in core profile.
pub fn unknown_directives(cfg : Config) -> Array[String] {
  analyze_config(cfg).unknown
}

///|
/// True when every non-comment directive belongs to the built-in core profile.
pub fn uses_known_directives_only(cfg : Config) -> Bool {
  unknown_directives(cfg).length() == 0
}

///|
/// Compact deterministic summary suitable for command-line diagnostics.
pub fn config_summary(cfg : Config) -> String {
  let s = analyze_config(cfg)
  "directives=" +
  s.directives.to_string() +
  ", blocks=" +
  s.blocks.to_string() +
  ", simple=" +
  s.simple.to_string() +
  ", comments=" +
  s.comments.to_string() +
  ", max_depth=" +
  s.max_depth.to_string() +
  ", servers=" +
  s.servers.to_string() +
  ", locations=" +
  s.locations.to_string() +
  ", upstreams=" +
  s.upstreams.to_string() +
  ", includes=" +
  s.includes.to_string() +
  ", unknown=" +
  s.unknown.length().to_string()
}
