///|
pub(all) enum TokKind {
  Word
  Quoted
  LBrace
  RBrace
  Semi
  Comment
} derive(Eq, Debug)

///|
pub(all) struct Tok {
  kind : TokKind
  value : String
  line : Int
} derive(Eq, Debug)

///|
fn tok_word(value : String, line : Int) -> Tok {
  { kind: Word, value, line, }
}

///|
fn tok_quoted(value : String, line : Int) -> Tok {
  { kind: Quoted, value, line, }
}

///|
fn tok_lbrace(line : Int) -> Tok {
  { kind: LBrace, value: "{", line, }
}

///|
fn tok_rbrace(line : Int) -> Tok {
  { kind: RBrace, value: "}", line, }
}

///|
fn tok_semi(line : Int) -> Tok {
  { kind: Semi, value: ";", line, }
}

///|
fn tok_comment(value : String, line : Int) -> Tok {
  { kind: Comment, value, line, }
}

///|
fn tok_is_arg(t : Tok) -> Bool {
  match t.kind {
    Word => t.value != "{" && t.value != "}" && t.value != ";"
    Quoted => true
    LBrace => false
    RBrace => false
    Semi => false
    Comment => false
  }
}
