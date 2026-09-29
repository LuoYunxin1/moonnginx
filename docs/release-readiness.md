# Acceptance checklist

This document maps MoonNginx to the hackathon acceptance guide.

| Requirement | Evidence | Verification |
|---|---|---|
| MoonBit is the main implementation language | Root *.mbt sources, moon.mod, and MoonBit package layout | moon version --all, moon check |
| Public GitHub repository and clear history | https://github.com/LuoYunxin1/moonnginx, repository-local author is LuoYunxin1 | git log --oneline, GitHub Actions |
| Core functionality works | Lexer, parser, directive tree, dump, builder, query, JSON payload, and validation modules | moon test --target wasm-gc |
| Reproducible README and examples | Installation, API snippets, boundaries, and three runnable scenarios in README.md | moon run cmd/main --target wasm-gc |
| Continuous integration | .github/workflows/ci.yml | CI runs check, build, test, and demo |
| Runnable minimum example | cmd/main prints PARSE, BUILD, and VALIDATE results | moon run cmd/main --target wasm-gc |
| Core-path tests | Blackbox and whitebox tests cover parsing, dumping, building, querying, errors, and lexing | 22 tests currently pass locally |
| MoonCakes publication | LuoYunxin1/moonnginx@0.1.0 is published | moon whoami, moon view LuoYunxin1/moonnginx |
| OSI-approved license | LICENSE and moon.mod specify Apache-2.0 | License file and package metadata |

The package is intentionally not republished during routine GitHub maintenance. MoonCakes publication is handled separately when a new package version is ready.
