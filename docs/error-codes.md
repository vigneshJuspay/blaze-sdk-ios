# Error codes

Error codes the SDK can send in `payload.errorCode`.

| Code | When | What to do | Retry as is? |
| --- | --- | --- | --- |
| `PAYLOAD_INVALID` | The `initiate` or `process` payload could not be read, or the `initiate` payload has no `publisherId`. `errorDetails` says which | Fix the payload and call again | No |

<!-- passthrough-error-codes
The codes below come from the web page the SDK opens, not from the SDK's own code.
List each one on its own line, or CI fails.
PAYLOAD_INVALID
-->
