///|
fn needs_quote(s : String) -> Bool {
  if s.length() == 0 {
    return true
  }
  let mut i = 0
  while i < s.length() {
    let ch = s[i].to_int()
    if is_ws(ch) || is_special(ch) || ch == 35 || ch == 34 || ch == 39 {
      return true
    }
    i = i + 1
  }
  false
}

///|
fn quote_arg(s : String) -> String {
  let mut out = "\""
  let mut i = 0
  while i < s.length() {
    let ch = s[i].to_int()
    if ch == 34 {
      out = out + "\\\""
    } else {
      out = out + slice_text(s, i, i + 1)
    }
    i = i + 1
  }
  out + "\""
}

///|
fn render_arg(s : String, quoted : Bool) -> String {
  if quoted || needs_quote(s) {
    quote_arg(s)
  } else {
    s
  }
}

///|
fn dump_directive(d : Directive, indent : Int) -> String {
  let pad = indent_spaces(indent)
  if d.name == "#" {
    match d.comment {
      Some(c) => pad + "#" + c
      None => pad + "#"
    }
  } else {
    let mut line = pad + d.name
    let mut i = 0
    while i < d.args.length() {
      let q = if i < d.quoted.length() { d.quoted[i] } else { false }
      line = line + " " + render_arg(d.args[i], q)
      i = i + 1
    }
    if d.has_block {
      let mut out = line + " {"
      let mut j = 0
      while j < d.children.length() {
        out = out + "\n" + dump_directive(d.children[j], indent + 4)
        j = j + 1
      }
      if d.children.length() == 0 {
        out + "\n" + pad + "}"
      } else {
        out + "\n" + pad + "}"
      }
    } else {
      line + ";"
    }
  }
}

///|
pub fn dump_conf(cfg : Config) -> String {
  let mut out = ""
  let mut i = 0
  while i < cfg.parsed.length() {
    if i > 0 {
      out = out + "\n"
    }
    out = out + dump_directive(cfg.parsed[i], 0)
    i = i + 1
  }
  if out.length() == 0 {
    out
  } else {
    out + "\n"
  }
}

///|
pub fn roundtrip(text : String) -> Result[String, NgxError] {
  match parse_conf(text) {
    Ok(cfg) => Ok(dump_conf(cfg))
    Err(e) => Err(e)
  }
}
