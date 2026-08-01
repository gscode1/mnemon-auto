#!/bin/sh
# mnemon-auto installer. Idempotent; never edits shell rc files.
set -e

src=$(cd -P -- "$(dirname -- "$0")" && pwd -P)/mnemon
dest_dir=$HOME/.local/bin
dest=$dest_dir/mnemon

if [ "$1" = "--uninstall" ]; then
    rm -f "$dest"
    echo "Removed $dest"
    exit 0
fi

if ! command -v mnemon >/dev/null 2>&1 || [ "$(command -v mnemon)" = "$dest" ]; then
    echo "mnemon not found on PATH; install it first: https://github.com/mnemon-dev/mnemon#install" >&2
    exit 1
fi

mkdir -p "$dest_dir"
cp "$src" "$dest"
chmod +x "$dest"
echo "Installed shim to $dest"

resolved=$(command -v mnemon)
if [ "$resolved" != "$dest" ]; then
    echo "Shim is not first on PATH. Add this line to your shell rc file:" >&2
    echo "  PATH=\"\$HOME/.local/bin:\$PATH\"" >&2
    exit 1
fi
echo "OK: 'mnemon' now resolves to the shim."
