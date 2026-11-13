# Security and prepublication checks

This public repository must not contain real credentials, personal device details, or private user identifiers. Do not copy detector examples or secret-like formats into documentation; describe detection categories in prose.

## Required before publishing

1. After cloning, run `bash scripts/install-hooks.sh` once.
2. Commit changes. The pre-commit hook inspects staged content and blocks absolute local paths, credential-like values, private network addresses, and sensitive filenames.
3. Before every push, the pre-push hook scans all outgoing commits and stops publication if a finding is present.
4. Open a pull request only after both local hooks pass. GitHub Actions repeats a smoke test for the hooks.

GitHub-based file creation bypasses local Git hooks. Run the same content scan before any public API write.

## Manual check

Run `bash scripts/pre-commit-check.sh` before committing. It checks staged blobs, the exact content included in the commit.

## If information is exposed

Immediately revoke real credentials and notify the data owner and security contact. Removing a file does not remove it from history or public caches. Follow the organization incident process for history cleanup and public branch updates.
