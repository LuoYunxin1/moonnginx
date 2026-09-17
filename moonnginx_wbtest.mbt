///|
test "lex words and specials" {
  let toks = match lex_conf("worker_processes 4;\n") {
    Ok(xs) => xs
    Err(e) => abort(e.message())
  }
  assert_eq(toks.length(), 3)
  assert_eq(toks[0].kind, Word)
  assert_eq(toks[0].value, "worker_processes")
  assert_eq(toks[1].value, "4")
  assert_eq(toks[2].kind, Semi)
}

///|
test "lex quoted and comment" {
  let toks = match lex_conf("# x\nadd_header A \"b c\";\n") {
    Ok(xs) => xs
    Err(e) => abort(e.message())
  }
  assert_eq(toks[0].kind, Comment)
  assert_eq(toks[3].kind, Quoted)
  assert_eq(toks[3].value, "b c")
}

///|
test "lex braces depth" {
  let toks = match lex_conf("http { server { } }\n") {
    Ok(xs) => xs
    Err(e) => abort(e.message())
  }
  let mut braces = 0
  let mut i = 0
  while i < toks.length() {
    match toks[i].kind {
      LBrace => braces += 1
      RBrace => braces += 1
      _ => ()
    }
    i = i + 1
  }
  assert_eq(braces, 4)
}
