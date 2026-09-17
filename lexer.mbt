///|
fn lex_conf(src : String) -> Result[Array[Tok], NgxError] {
  let c = cursor_new(src)
  let toks : Array[Tok] = []
  let mut depth = 0
  while !cursor_eof(c) {
    skip_ws(c)
    if cursor_eof(c) {
      break
    }
    let line = c.line
    let ch = cursor_peek(c)
    if ch == 35 {
      cursor_bump(c)
      let start = c.i
      while !cursor_eof(c) && !is_eol(cursor_peek(c)) {
        cursor_bump(c)
      }
      toks.push(tok_comment(slice_text(src, start, c.i), line))
      continue
    }
    if ch == 34 || ch == 39 {
      match lex_quoted(c, ch) {
        Ok(s) => toks.push(tok_quoted(s, line))
        Err(e) => return Err(e)
      }
      continue
    }
    if ch == 123 {
      depth += 1
      cursor_bump(c)
      toks.push(tok_lbrace(line))
      continue
    }
    if ch == 125 {
      depth -= 1
      if depth < 0 {
        return Err(Unexpected(line_msg(line, "unexpected }")))
      }
      cursor_bump(c)
      toks.push(tok_rbrace(line))
      continue
    }
    if ch == 59 {
      cursor_bump(c)
      toks.push(tok_semi(line))
      continue
    }
    match lex_word(c) {
      Ok(w) => {
        if w == "" {
          return Err(Syntax(line_msg(line, "empty token")))
        }
        toks.push(tok_word(w, line))
      }
      Err(e) => return Err(e)
    }
  }
  if depth > 0 {
    return Err(
      Unterminated(line_msg(c.line, "unexpected end of file, expecting }")),
    )
  }
  Ok(toks)
}

///|
fn lex_quoted(c : Cursor, quote : Int) -> Result[String, NgxError] {
  let line = c.line
  cursor_bump(c)
  let mut s = ""
  while !cursor_eof(c) {
    let ch = cursor_peek(c)
    if ch == 92 {
      cursor_bump(c)
      if cursor_eof(c) {
        return Err(
          Unterminated(line_msg(line, "escape at end of quoted string")),
        )
      }
      let nxt = cursor_peek(c)
      if nxt == quote {
        s = s + slice_text(c.src, c.i, c.i + 1)
        cursor_bump(c)
      } else {
        s = s + "\\" + slice_text(c.src, c.i, c.i + 1)
        cursor_bump(c)
      }
      continue
    }
    if ch == quote {
      cursor_bump(c)
      return Ok(s)
    }
    s = s + slice_text(c.src, c.i, c.i + 1)
    cursor_bump(c)
  }
  Err(Unterminated(line_msg(line, "quoted string")))
}

///|
fn lex_word(c : Cursor) -> Result[String, NgxError] {
  let start_line = c.line
  let mut s = ""
  while !cursor_eof(c) {
    let ch = cursor_peek(c)
    if is_ws(ch) || is_special(ch) {
      break
    }
    if ch == 35 && s == "" {
      break
    }
    if ch == 34 || ch == 39 {
      if s == "" {
        break
      }
      s = s + slice_text(c.src, c.i, c.i + 1)
      cursor_bump(c)
      continue
    }
    if ch == 92 {
      cursor_bump(c)
      if cursor_eof(c) {
        return Err(Unterminated(line_msg(start_line, "escape at end of word")))
      }
      s = s + "\\" + slice_text(c.src, c.i, c.i + 1)
      cursor_bump(c)
      continue
    }
    if ch == 36 {
      s = s + "$"
      cursor_bump(c)
      if cursor_peek(c) == 123 {
        s = s + "{"
        cursor_bump(c)
        while !cursor_eof(c) {
          let inner = cursor_peek(c)
          s = s + slice_text(c.src, c.i, c.i + 1)
          cursor_bump(c)
          if inner == 125 {
            break
          }
        }
      }
      continue
    }
    s = s + slice_text(c.src, c.i, c.i + 1)
    cursor_bump(c)
  }
  Ok(s)
}
