# Security and prepublication checks

This public repository must not contain real credentials, personal device details, or private user identifiers. Do not copy detector examples or secret-like formats into documentation; describe detection categories in prose.

## Required before publishing

1. After cloning, run `bash scripts/install-hooks.sh` once.
2. Commit changes. The pre-commit hook inspects staged content and blocks absolute local paths, credential-like values, private network addresses, and sensitive filenames. Warnings are blocking too.
3. Push and open a pull request only after the hook passes.
4. Wait for the GitHub Actions hook smoke test to pass before merging.

GitHub-based file creation must receive the same content scan before any public write. A repository hook and a server-side check are separate safeguards.

## Manual check

Run `bash scripts/pre-commit-check.sh` before committing. It checks staged blobs, which are the actual contents included in the commit.

## If information is exposed

Immediately revoke real credentials and notify the data owner and security contact. Removing a file does not remove it from history or public caches. Follow the organization incident process for history cleanup and public branch updates.
