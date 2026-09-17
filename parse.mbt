///|
priv struct Parser {
  toks : Array[Tok]
  mut i : Int
  file : String
}

///|
fn parser_eof(p : Parser) -> Bool {
  p.i >= p.toks.length()
}

///|
fn parser_peek(p : Parser) -> Tok? {
  if parser_eof(p) {
    None
  } else {
    Some(p.toks[p.i])
  }
}

///|
fn parser_bump(p : Parser) -> Unit {
  if !parser_eof(p) {
    p.i += 1
  }
}

///|
pub fn parse_conf(text : String) -> Result[Config, NgxError] {
  parse_conf_named("nginx.conf", text)
}

///|
pub fn parse_conf_named(
  file : String,
  text : String,
) -> Result[Config, NgxError] {
  match lex_conf(text) {
    Err(e) => Err(e)
    Ok(toks) => {
      let p : Parser = { toks, i: 0, file, }
      match parse_stmts(p, false) {
        Err(e) => Err(e)
        Ok(parsed) =>
          if !parser_eof(p) {
            match parser_peek(p) {
              Some(t) =>
                match t.kind {
                  RBrace => Err(Unexpected(line_msg(t.line, "unexpected }")))
                  _ =>
                    Err(
                      Syntax(
                        line_msg(t.line, p.file + " trailing token " + t.value),
                      ),
                    )
                }
              None => Ok(config_ok(file, parsed))
            }
          } else {
            Ok(config_ok(file, parsed))
          }
      }
    }
  }
}

///|
fn parse_stmts(
  p : Parser,
  in_block : Bool,
) -> Result[Array[Directive], NgxError] {
  let out : Array[Directive] = []
  while !parser_eof(p) {
    match parser_peek(p) {
      None => break
      Some(t) =>
        match t.kind {
          RBrace =>
            if in_block {
              parser_bump(p)
              return Ok(out)
            } else {
              return Err(Unexpected(line_msg(t.line, "unexpected }")))
            }
          Comment => {
            out.push(dir_comment(t.value, t.line))
            parser_bump(p)
          }
          LBrace => return Err(Unexpected(line_msg(t.line, "unexpected {")))
          Semi => return Err(Unexpected(line_msg(t.line, "unexpected ;")))
          Quoted =>
            return Err(
              Syntax(line_msg(t.line, "quoted string cannot start a directive")),
            )
          Word =>
            match parse_stmt(p) {
              Ok(d) => out.push(d)
              Err(e) => return Err(e)
            }
        }
    }
  }
  if in_block {
    Err(Unterminated(p.file + ": unexpected end of file, expecting }"))
  } else {
    Ok(out)
  }
}

///|
fn parse_stmt(p : Parser) -> Result[Directive, NgxError] {
  match parser_peek(p) {
    None => Err(Syntax("premature end of file"))
    Some(head) => {
      let name = head.value
      let line = head.line
      parser_bump(p)
      let args : Array[String] = []
      let quoted : Array[Bool] = []
      while !parser_eof(p) {
        match parser_peek(p) {
          None => break
          Some(t) =>
            if tok_is_arg(t) {
              args.push(t.value)
              quoted.push(
                match t.kind {
                  Quoted => true
                  _ => false
                },
              )
              parser_bump(p)
            } else {
              break
            }
        }
      }
      if parser_eof(p) {
        return Err(Unterminated(line_msg(line, "premature end of file")))
      }
      match parser_peek(p) {
        None => Err(Unterminated(line_msg(line, "premature end of file")))
        Some(term) =>
          match term.kind {
            Semi => {
              parser_bump(p)
              let d = finish_stmt(name, line, args, quoted, [], false)
              Ok(d)
            }
            LBrace => {
              parser_bump(p)
              match parse_stmts(p, true) {
                Err(e) => Err(e)
                Ok(kids) =>
                  Ok(finish_stmt(name, line, args, quoted, kids, true))
              }
            }
            RBrace =>
              Err(
                Syntax(
                  line_msg(
                    line,
                    "directive " + name + " is not terminated by ;",
                  ),
                ),
              )
            _ => Err(Unexpected(line_msg(term.line, "token " + term.value)))
          }
      }
    }
  }
}

///|
fn finish_stmt(
  name : String,
  line : Int,
  args : Array[String],
  quoted : Array[Bool],
  children : Array[Directive],
  has_block : Bool,
) -> Directive {
  let (a2, q2) = if name == "if" {
    strip_if_parens(args, quoted)
  } else {
    (args, quoted)
  }
  { name, line, args: a2, quoted: q2, children, has_block, comment: None, }
}

///|
fn strip_if_parens(
  args : Array[String],
  quoted : Array[Bool],
) -> (Array[String], Array[Bool]) {
  if args.length() == 0 {
    return (args, quoted)
  }
  let first = args[0]
  let last = args[args.length() - 1]
  if !(first.has_prefix("(") && last.has_suffix(")")) {
    return (args, quoted)
  }
  let out_a : Array[String] = []
  let out_q : Array[Bool] = []
  let mut i = 0
  while i < args.length() {
    let mut s = args[i]
    if i == 0 {
      s = slice_text(s, 1, s.length())
    }
    if i == args.length() - 1 {
      if s.length() > 0 {
        s = slice_text(s, 0, s.length() - 1)
      }
    }
    if s.length() > 0 {
      out_a.push(s)
      out_q.push(quoted[i])
    }
    i = i + 1
  }
  (out_a, out_q)
}
