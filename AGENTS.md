# imgwire-ruby Agent Notes

- `generated/` is disposable output from OpenAPI Generator. Do not hand-edit generated files.
- Use `yarn generate` to refresh `openapi/sdk.openapi.json`, `generated/`, and `CODEGEN_VERSION`.
- `@imgwire/codegen-core` is the source of truth for OpenAPI shaping.
- Yarn Classic is used for codegen tooling. Ruby packaging uses Bundler and RubyGems.
- Handwritten SDK behavior belongs in `lib/`, `spec/`, and `docs/`.
- CI runs `yarn verify-generated` and fails when generated artifacts or `CODEGEN_VERSION` are stale.
