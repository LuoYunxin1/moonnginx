///|
/// One nginx statement: simple, block, or comment.
pub(all) struct Directive {
  name : String
  line : Int
  args : Array[String]
  quoted : Array[Bool]
  children : Array[Directive]
  has_block : Bool
  comment : String?
} derive(Eq, Debug)

///|
pub(all) struct Config {
  file : String
  parsed : Array[Directive]
  status : String
} derive(Eq, Debug)

///|
pub fn dir_simple(name : String, args : Array[String], line : Int) -> Directive {
  {
    name,
    line,
    args,
    quoted: bools_false(args.length()),
    children: [],
    has_block: false,
    comment: None,
  }
}

///|
pub fn dir_block(
  name : String,
  args : Array[String],
  children : Array[Directive],
  line : Int,
) -> Directive {
  {
    name,
    line,
    args,
    quoted: bools_false(args.length()),
    children,
    has_block: true,
    comment: None,
  }
}

///|
pub fn dir_comment(text : String, line : Int) -> Directive {
  {
    name: "#",
    line,
    args: [],
    quoted: [],
    children: [],
    has_block: false,
    comment: Some(text),
  }
}

///|
pub fn Directive::is_comment(self : Directive) -> Bool {
  self.name == "#"
}

///|
pub fn Directive::is_include(self : Directive) -> Bool {
  self.name == "include"
}

///|
pub fn Directive::is_block(self : Directive) -> Bool {
  self.has_block
}

///|
pub fn empty_config(file : String) -> Config {
  { file, parsed: [], status: "ok", }
}

///|
pub fn config_ok(file : String, parsed : Array[Directive]) -> Config {
  { file, parsed, status: "ok", }
}

///|
fn find_named(xs : Array[Directive], name : String) -> Array[Directive] {
  let out : Array[Directive] = []
  let mut i = 0
  while i < xs.length() {
    if xs[i].name == name {
      out.push(xs[i])
    }
    i = i + 1
  }
  out
}

///|
pub fn Config::find(self : Config, name : String) -> Array[Directive] {
  find_named(self.parsed, name)
}

///|
fn walk_named(
  xs : Array[Directive],
  name : String,
  out : Array[Directive],
) -> Unit {
  let mut i = 0
  while i < xs.length() {
    if xs[i].name == name {
      out.push(xs[i])
    }
    if xs[i].has_block {
      walk_named(xs[i].children, name, out)
    }
    i = i + 1
  }
}

///|
pub fn Config::find_all(self : Config, name : String) -> Array[Directive] {
  let out : Array[Directive] = []
  walk_named(self.parsed, name, out)
  out
}
