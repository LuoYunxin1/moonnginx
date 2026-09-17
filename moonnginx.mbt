///|
pub fn library_name() -> String {
  "LuoYunxin1/moonnginx"
}

///|
pub fn syntax_profile() -> String {
  "nginx-1.26-oss-core"
}

///|
pub fn supported_blocks() -> Array[String] {
  [
    "events", "http", "server", "location", "upstream", "if", "limit_except", "map",
    "geo", "types", "stream", "mail",
  ]
}

///|
pub fn parse_dump(text : String) -> Result[String, NgxError] {
  roundtrip(text)
}
