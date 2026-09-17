///|
priv struct Cursor {
  src : String
  mut i : Int
  mut line : Int
}

///|
fn cursor_new(src : String) -> Cursor {
  { src, i: 0, line: 1, }
}

///|
fn cursor_eof(c : Cursor) -> Bool {
  c.i >= c.src.length()
}

///|
fn cursor_peek(c : Cursor) -> Int {
  if cursor_eof(c) {
    -1
  } else {
    c.src[c.i].to_int()
  }
}

///|
fn cursor_bump(c : Cursor) -> Unit {
  if !cursor_eof(c) {
    if c.src[c.i].to_int() == 10 {
      c.line += 1
    }
    c.i += 1
  }
}

///|
fn slice_text(s : String, start : Int, end : Int) -> String {
  s[start:end].to_owned()
}

///|
fn is_ws(ch : Int) -> Bool {
  ch == 32 || ch == 9 || ch == 10 || ch == 13
}

///|
fn is_eol(ch : Int) -> Bool {
  ch == 10
}

///|
fn is_special(ch : Int) -> Bool {
  ch == 123 || ch == 125 || ch == 59
}

///|
fn skip_ws(c : Cursor) -> Unit {
  while !cursor_eof(c) && is_ws(cursor_peek(c)) {
    cursor_bump(c)
  }
}

///|
fn map_from_pairs(pairs : Array[(String, Json)]) -> Map[String, Json] {
  let m : Map[String, Json] = Map([])
  let mut i = 0
  while i < pairs.length() {
    let (k, v) = pairs[i]
    m[k] = v
    i = i + 1
  }
  m
}

///|
fn json_int(n : Int) -> Json {
  Json::number(n.to_double(), repr=n.to_string())
}

///|
fn bools_false(n : Int) -> Array[Bool] {
  let xs : Array[Bool] = []
  let mut i = 0
  while i < n {
    xs.push(false)
    i = i + 1
  }
  xs
}

///|
fn indent_spaces(n : Int) -> String {
  let mut s = ""
  let mut i = 0
  while i < n {
    s = s + " "
    i = i + 1
  }
  s
}
