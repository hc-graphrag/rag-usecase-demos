#!/usr/bin/env bash
# Scan the exact staged blobs before a commit. Any finding blocks publication.
set -euo pipefail

errors=0
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

while IFS= read -r -d '' path; do
    name=${path##*/}
    case "$name" in
        .env|.env.*|*.pem|*.key|*.p12|*.pfx|*.jks|id_rsa*|id_ed25519*|credentials|credentials.*|secrets|secrets.*)
            printf 'BLOCKED: sensitive filename staged (%s)\n' "$path"
            errors=$((errors + 1))
            ;;
    esac
    if ! content=$(git show ":$path" 2>/dev/null); then
        printf 'BLOCKED: unable to inspect staged content (%s)\n' "$path"
        errors=$((errors + 1))
        continue
    fi
    if printf '%s' "$content" | grep -qE "$local_path_re"; then
        printf 'BLOCKED: local or temporary absolute path in staged file (%s)\n' "$path"
        errors=$((errors + 1))
    fi
    if printf '%s' "$content" | grep -qE "$private_ip_re"; then
        printf 'BLOCKED: private network address in staged file (%s)\n' "$path"
        errors=$((errors + 1))
    fi
    if printf '%s' "$content" | grep -qE "$api_token_re"; then
        printf 'BLOCKED: token-like value in staged file (%s)\n' "$path"
        errors=$((errors + 1))
    fi
    if printf '%s' "$content" | grep -qiE "$assignment_re"; then
        printf 'BLOCKED: hard-coded credential assignment in staged file (%s)\n' "$path"
        errors=$((errors + 1))
    fi
done < <(git diff --cached --name-only --diff-filter=ACMR -z)
if [ "$errors" -gt 0 ]; then
    printf 'Commit stopped: remove the findings before committing.\n'
    exit 1
fi
printf 'Pre-commit security check passed.\n'
