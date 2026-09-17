# Duplicate check — MoonNginx — 2026-09-17

- Candidate: nginx.conf directive-tree codec (lex / AST / dump / builder / core context).
- osc2026-guide: invoked; MoonCakes research via `moon search`.
- moon search:
  - `nginx.conf` — no modules
  - `ngx_` — no modules
  - `crossplane` — no modules
  - `openresty` — unrelated false hits
  - `nginx` — BeiLaDuo/cidr-audit only (allow/deny import for CIDR audit)
  - `haproxy` — P7001/moon-proxyproto (PROXY v1/v2 headers, not haproxy.cfg)
  - `caddy` — Candy Crush false hit
  - `makefile` — cli/make already occupies GNU Make; rejected as alternative
  - `dockerfile` — mizchi/syntree/dockerfile highlighter; rejected as alternative
- Local registry index (2519 packages): no nginx.conf AST library.
- Adjacent-not-same: jingmo653/sshconfig-resolve (OpenSSH client config); editorconfig/dotenv/hcl/ini (other config languages); cidr-audit; moon-proxyproto; syntree dockerfile tokenizer.
- Rejected alternatives: Dockerfile AST (highlighter neighbourhood), E.164 phonenumber (record-linkage phone normalization), Makefile (cli/make).
- Decision: proceed. No directly overlapping mature nginx.conf codec.
