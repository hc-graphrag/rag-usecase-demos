#!/usr/bin/env bash
set -euo pipefail
source_root=$(git rev-parse --show-toplevel)
test_repo=$(mktemp -d)
test_remote=$(mktemp -d)
trap 'rm -rf "$test_repo" "$test_remote"' EXIT
mkdir -p "$test_repo/scripts" "$test_repo/.githooks"
cp "$source_root/scripts/pre-commit-check.sh" "$test_repo/scripts/"
cp "$source_root/scripts/install-hooks.sh" "$test_repo/scripts/"
cp "$source_root/.githooks/pre-commit" "$test_repo/.githooks/"
cp "$source_root/.githooks/pre-push" "$test_repo/.githooks/"
git init -q "$test_repo"
git -C "$test_repo" config user.name "Hook Test"
git -C "$test_repo" config user.email "hook-test@example.invalid"
git init -q --bare "$test_remote"
git -C "$test_repo" remote add origin "$test_remote"
(
    cd "$test_repo"
    bash scripts/install-hooks.sh
    printf 'safe synthetic content\n' > README.md
    git add README.md scripts .githooks
    git commit -m "install hooks" >/dev/null
    git push origin HEAD:refs/heads/main >/dev/null
    printf '%s%s%s%s%s\n' 'C:' '\' 'Users' '\' 'reviewer' > local-path.md
    git add local-path.md
    if git commit -m "must block local path" >/dev/null 2>&1; then
        echo "Pre-commit hook failed to block a local path."
        exit 1
    fi
    git reset --hard HEAD >/dev/null
    printf '%s = "%s"\n' 'pass''word' 'not-a-real-value' > credential.md
    git add credential.md
    if git commit -m "must block credentials" >/dev/null 2>&1; then
        echo "Pre-commit hook failed to block credentials."
        exit 1
    fi
    git reset --hard HEAD >/dev/null
    : > .env
    git add .env
    if git commit -m "must block sensitive filename" >/dev/null 2>&1; then
        echo "Pre-commit hook failed to block sensitive filename."
        exit 1
    fi
    git reset --hard HEAD >/dev/null
    printf '%s%s%s%s%s\n' 'C:' '\' 'Users' '\' 'reviewer' > local-path.md
    git add local-path.md
    git -c core.hooksPath=/dev/null commit -m "simulate hook bypass before push" >/dev/null
    if git push origin HEAD:refs/heads/main >/dev/null 2>&1; then
        echo "Pre-push hook failed to block an unpublished local path."
        exit 1
    fi
)
echo "Pre-commit and pre-push hook smoke tests passed."
