///|
fn parent_ctx(stack : Array[String]) -> String {
  if stack.length() == 0 {
    "main"
  } else {
    stack[stack.length() - 1]
  }
}

///|
fn enter_ctx(name : String, cur : String) -> String {
  if name == "events" {
    "events"
  } else if name == "http" {
    "http"
  } else if name == "stream" {
    "stream"
  } else if name == "mail" {
    "mail"
  } else if name == "server" {
    if cur == "upstream" {
      cur
    } else {
      "server"
    }
  } else if name == "location" {
    "location"
  } else if name == "upstream" {
    "upstream"
  } else if name == "if" {
    "if"
  } else if name == "limit_except" {
    "limit_except"
  } else if name == "map" ||
    name == "geo" ||
    name == "split_clients" ||
    name == "types" {
    "map"
  } else {
    cur
  }
}

///|
fn validate_dir(d : Directive, stack : Array[String]) -> Result[Unit, NgxError] {
  if d.name == "#" {
    return Ok(())
  }
  let cur = parent_ctx(stack)
  if cur == "map" {
    return Ok(())
  }
  match lookup_spec(d.name, cur) {
    None => Ok(())
    Some(sp) => {
      if !ctx_in(sp.ctxs, cur) {
        return Err(
          Constraint(
            line_msg(
              d.line,
              "directive " + d.name + " is not allowed in " + cur,
            ),
          ),
        )
      }
      let n = d.args.length()
      if n < sp.min_args || n > sp.max_args {
        return Err(
          Constraint(
            line_msg(
              d.line,
              "invalid number of arguments in " + d.name + " directive",
            ),
          ),
        )
      }
      if sp.form == 1 && !d.has_block {
        return Err(
          Constraint(
            line_msg(d.line, "directive " + d.name + " requires a block"),
          ),
        )
      }
      if sp.form == 0 && d.has_block {
        return Err(
          Constraint(
            line_msg(d.line, "directive " + d.name + " is not terminated by ;"),
          ),
        )
      }
      if d.has_block {
        let next = enter_ctx(d.name, cur)
        let st2 : Array[String] = []
        let mut i = 0
        while i < stack.length() {
          st2.push(stack[i])
          i = i + 1
        }
        st2.push(next)
        validate_list(d.children, st2)
      } else {
        Ok(())
      }
    }
  }
}

///|
fn validate_list(
  xs : Array[Directive],
  stack : Array[String],
) -> Result[Unit, NgxError] {
  let mut i = 0
  while i < xs.length() {
    match validate_dir(xs[i], stack) {
      Err(e) => return Err(e)
      Ok(_) => ()
    }
    i = i + 1
  }
  Ok(())
}

///|
pub fn validate_core(cfg : Config) -> Result[Unit, NgxError] {
  validate_list(cfg.parsed, [])
}

///|
pub fn parse_and_validate(text : String) -> Result[Config, NgxError] {
  match parse_conf(text) {
    Err(e) => Err(e)
    Ok(cfg) =>
      match validate_core(cfg) {
        Err(e) => Err(e)
        Ok(_) => Ok(cfg)
      }
  }
}
