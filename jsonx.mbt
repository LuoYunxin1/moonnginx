///|
fn json_args(args : Array[String]) -> Json {
  let xs : Array[Json] = []
  let mut i = 0
  while i < args.length() {
    xs.push(Json::string(args[i]))
    i = i + 1
  }
  Json::array(xs)
}

///|
fn json_directive(d : Directive) -> Json {
  let pairs : Array[(String, Json)] = [
    ("directive", Json::string(d.name)),
    ("line", json_int(d.line)),
    ("args", json_args(d.args)),
  ]
  if d.has_block {
    let kids : Array[Json] = []
    let mut i = 0
    while i < d.children.length() {
      kids.push(json_directive(d.children[i]))
      i = i + 1
    }
    pairs.push(("block", Json::array(kids)))
  }
  match d.comment {
    Some(c) => pairs.push(("comment", Json::string(c)))
    None => ()
  }
  Json::object(map_from_pairs(pairs))
}

///|
pub fn config_json(cfg : Config) -> Json {
  let dirs : Array[Json] = []
  let mut i = 0
  while i < cfg.parsed.length() {
    dirs.push(json_directive(cfg.parsed[i]))
    i = i + 1
  }
  Json::object(
    map_from_pairs([
      ("file", Json::string(cfg.file)),
      ("status", Json::string(cfg.status)),
      ("parsed", Json::array(dirs)),
    ]),
  )
}

///|
pub fn payload_json(cfg : Config) -> Json {
  Json::object(
    map_from_pairs([
      ("status", Json::string(cfg.status)),
      ("errors", Json::array([])),
      ("config", Json::array([config_json(cfg)])),
    ]),
  )
}

///|
pub fn payload_text(cfg : Config) -> String {
  payload_json(cfg).stringify()
}
