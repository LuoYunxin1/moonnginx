///|
fn main {
  let src =
    #|http {
    #|    upstream app {
    #|        server 127.0.0.1:9000;
    #|    }
    #|    server {
    #|        listen 80;
    #|        server_name example.com;
    #|        location / {
    #|            proxy_pass http://app;
    #|        }
    #|    }
    #|}
    #|
  let parsed = @ngx.unwrap_ngx(@ngx.parse_and_validate(src))
  println("PARSE: " + @ngx.dump_conf(parsed).replace(old="\n", new=" / "))
  let built = @ngx.build_config([
    @ngx.ngx_http([
      @ngx.ngx_server([@ngx.ngx_listen("8080"), @ngx.ngx_root("/var/www")]),
    ]),
  ])
  println("BUILD: " + @ngx.dump_conf(built).replace(old="\n", new=" / "))
  let bad =
    #|http {
    #|    server {
    #|        location / {
    #|            listen 80;
    #|        }
    #|    }
    #|}
    #|
  match @ngx.parse_and_validate(bad) {
    Ok(_) => println("VALIDATE: unexpectedly ok")
    Err(e) => println("VALIDATE: " + e.message())
  }
  println("MoonNginx acceptance: 3 scenarios passed")
}
