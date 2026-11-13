#!/usr/bin/env bash
# Inspect staged blobs before commits and committed blobs before publication.
set -euo pipefail
pass_word='pass''word'
secret_word='se''cret'
home_prefix='/ho''me/'
users_prefix='/Us''ers/'
tmp_prefix='/t''mp/'
var_tmp_prefix='/var/''tmp/'
win_prefix='C:'
win_separator='\\'
local_path_re="(${home_prefix}[^/]+/|${users_prefix}[^/]+/|${win_prefix}${win_separator}Users${win_separator}|${tmp_prefix}|${var_tmp_prefix})"
private_ip_re='(192[.]168[.][0-9]+[.][0-9]+|10[.][0-9]+[.][0-9]+[.][0-9]+|172[.](1[6-9]|2[0-9]|3[0-1])[.][0-9]+[.][0-9]+)'
api_token_re='(sk-[[:alnum:]]{32,}|ghp_[[:alnum:]]{36}|ghs_[[:alnum:]]{36}|github_pat_[[:alnum:]_]{22,}|xox[baprs]-[[:alnum:]-]+|AKIA[[:upper:]0-9]{16})'
assignment_re="(${pass_word}|${secret_word})[[:space:]]*[=:][[:space:]]*['\"][^'\"]+['\"]"
errors=0
scan_file() {
    local path="$1"
    local content="$2"
    local name=${path##*/}
    case "$name" in
        .env|.env.*|*.pem|*.key|*.p12|*.pfx|*.jks|id_rsa*|id_ed25519*|credentials|credentials.*|secrets|secrets.*)
            printf 'BLOCKED: sensitive filename (%s)\n' "$path"
            errors=$((errors + 1))
            ;;
    esac
    if printf '%s' "$content" | grep -qE "$local_path_re"; then
        printf 'BLOCKED: local or temporary absolute path (%s)\n' "$path"
        errors=$((errors + 1))
    fi
    if printf '%s' "$content" | grep -qE "$private_ip_re"; then
        printf 'BLOCKED: private network address (%s)\n' "$path"
        errors=$((errors + 1))
    fi
    if printf '%s' "$content" | grep -qE "$api_token_re"; then
        printf 'BLOCKED: token-like value (%s)\n' "$path"
        errors=$((errors + 1))
    fi
    if printf '%s' "$content" | grep -qiE "$assignment_re"; then
        printf 'BLOCKED: hard-coded credential assignment (%s)\n' "$path"
        errors=$((errors + 1))
    fi
}
if [ "${1:-}" = "--commit" ]; then
    commit="${2:?commit SHA required}"
    while IFS= read -r -d '' path; do
        if content=$(git show "$commit:$path" 2>/dev/null); then
            scan_file "$path" "$content"
        fi
    done < <(git diff-tree --root --no-commit-id --name-only -r -z "$commit")
elif [ "$#" -eq 0 ]; then
    while IFS= read -r -d '' path; do
        if ! content=$(git show ":$path" 2>/dev/null); then
            printf 'BLOCKED: unable to inspect staged content (%s)\n' "$path"
            errors=$((errors + 1))
            continue
        fi
        scan_file "$path" "$content"
    done < <(git diff --cached --name-only --diff-filter=ACMR -z)
else
    echo "Usage: pre-commit-check.sh [--commit SHA]" >&2
    exit 2
fi
if [ "$errors" -gt 0 ]; then
    printf 'Publication stopped: remove the findings before committing or pushing.\n'
    exit 1
fi
printf 'Security check passed.\n'
