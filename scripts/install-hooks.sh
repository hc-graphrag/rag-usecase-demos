#!/usr/bin/env bash
set -euo pipefail
repo_root=$(git rev-parse --show-toplevel)
chmod +x "$repo_root/.githooks/pre-commit"
git -C "$repo_root" config --local core.hooksPath .githooks
printf 'Enabled the repository pre-commit security hook.\n'
