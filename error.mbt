///|
/// nginx.conf codec errors.
pub(all) enum NgxError {
  Syntax(String)
  Unexpected(String)
  Unterminated(String)
  Constraint(String)
  NotImplemented(String)
} derive(Eq, Debug)

///|
pub fn NgxError::message(self : NgxError) -> String {
  match self {
    Syntax(s) => "syntax: " + s
    Unexpected(s) => "unexpected: " + s
    Unterminated(s) => "unterminated: " + s
    Constraint(s) => "constraint: " + s
    NotImplemented(s) => "not-implemented: " + s
  }
}

///|
pub fn[T] unwrap_ngx(r : Result[T, NgxError]) -> T {
  match r {
    Ok(v) => v
    Err(e) => abort(e.message())
  }
}

///|
pub fn line_msg(line : Int, msg : String) -> String {
  "line " + line.to_string() + ": " + msg
}
