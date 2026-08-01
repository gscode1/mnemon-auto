#!/bin/sh
# Smoke test for the mnemon-auto shim. Exits non-zero on any failure.
set -e
cd "$(dirname -- "$0")"
shim=$PWD/mnemon
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }

db_path() { echo "$1" | sed -n 's/.*"db_path": *"\([^"]*\)".*/\1/p'; }

# Two temp git repos -> different stores named after the repo.
out1=$(cd "$tmp" && git init -q "My Proj" && cd "My Proj" && "$shim" status)
out2=$(cd "$tmp" && git init -q other && cd other && "$shim" status)
p1=$(db_path "$out1"); p2=$(db_path "$out2")
[ "$p1" != "$p2" ] || fail "same db_path for different repos"
echo "$p1" | grep -q '/my-proj/mnemon.db' || fail "repo1 db_path not sanitized 'my-proj': $p1"
echo "$p2" | grep -q '/other/mnemon.db' || fail "repo2 db_path not 'other': $p2"

# --global hits the global store.
p3=$(db_path "$(cd "$tmp/other" && "$shim" --global status)")
echo "$p3" | grep -q '/global/mnemon.db' || fail "--global did not hit global store: $p3"

# MNEMON_STORE bypasses derivation.
p4=$(db_path "$(cd "$tmp/other" && MNEMON_STORE=envx "$shim" status)")
echo "$p4" | grep -q '/envx/mnemon.db' || fail "MNEMON_STORE bypass broken: $p4"

# store subcommand passes through unshimmed.
"$shim" store list >/dev/null || fail "store list passthrough failed"
out5=$("$shim" store list)
case $out5 in *my-proj*other*) ;; *) fail "store list looks shimmed: $out5" ;; esac

# Clean up every store created.
mnemon store remove my-proj >/dev/null
mnemon store remove other >/dev/null
mnemon store remove envx >/dev/null

echo "PASS: all shim checks"
