// Error codes the SDK sends; send them as BlazeErrorCodes.X, never as strings.
// When you add a code here, add a row for it to the table in docs/error-codes.md: when it is
// sent, what the app should do, and whether retrying the same call can work.
// CI (scripts/verify-error-codes.sh) fails if a code here has no row in that table.
enum BlazeErrorCodes {}
