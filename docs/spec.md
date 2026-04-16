# SDK Layout

- `openapi/raw.openapi.json`: captured raw upstream OpenAPI input
- `openapi/sdk.openapi.json`: Ruby-target shaped OpenAPI emitted by `@imgwire/codegen-core`
- `generated/`: disposable OpenAPI Generator output
- `lib/`: handwritten Ruby API surface, uploads, pagination, and image URL helpers

Regeneration flow:

```text
Raw OpenAPI
-> buildSdkSpec({ target: "ruby" })
-> openapi/sdk.openapi.json
-> OpenAPI Generator (ruby)
-> generated/
-> postprocess cleanup
-> CODEGEN_VERSION update
```
