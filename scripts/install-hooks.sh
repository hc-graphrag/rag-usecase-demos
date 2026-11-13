#!/usr/bin/env bash
set -euo pipefail
repo_root=$(git rev-parse --show-toplevel)
chmod +x "$repo_root/.githooks/pre-commit" "$repo_root/.githooks/pre-push"
git -C "$repo_root" config --local core.hooksPath .githooks
printf 'Enabled the repository pre-commit and pre-push security hooks.\n'
