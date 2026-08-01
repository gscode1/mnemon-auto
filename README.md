# mnemon-auto

Per-project memory for [mnemon](https://github.com/mnemon-dev/mnemon), with zero setup per project.

## The problem

mnemon saves everything to one global store unless you pass `--store` or set `MNEMON_STORE` on every call. Nobody does — so memories from all your projects pile up together.

## The fix

mnemon-auto is a tiny shim in front of the real `mnemon` binary. It picks the store from the git repo you're in. You use `mnemon` exactly as before — it just lands in the right place.

```
# before: everything lands in one global store
$ mnemon remember "api uses port 8080"   # -> ~/.mnemon/data/global/  (mixed with every other project)

# after: the store follows the repo you're in
$ mnemon remember "api uses port 8080"   # -> ~/.mnemon/data/my-api/
$ cd ../other-repo && mnemon status      # -> ~/.mnemon/data/other-repo/
```

## Install

```sh
git clone https://github.com/gscode1/mnemon-auto
cd mnemon-auto && ./install.sh
```

Or one line:

```sh
curl -fsSL https://raw.githubusercontent.com/gscode1/mnemon-auto/main/mnemon -o ~/.local/bin/mnemon && chmod +x ~/.local/bin/mnemon
```

Requires the real `mnemon` installed and `~/.local/bin` ahead of it on PATH. The installer checks both and prints the exact fix if something's off.

## How it works

- **PATH shim**: installs to `~/.local/bin/mnemon`, finds the real binary further down PATH, and hands off to it — args, output, and exit codes pass through untouched.
- **Store from git**: inside a repo, the store is the repo folder name (lowercased, cleaned up). Outside a repo, it's the current folder name.
- **Auto-create**: new stores are created on first use. Nothing to configure.
- **Easy bypass**: `--store`, `MNEMON_STORE`, `--global` (first arg = global store), and the `store`/`setup`/`help`/`completion` subcommands all skip the shim.

Works with any agent harness (pi, Claude Code, Cursor, …) that shells out to `mnemon` — they all hit the shim.

## Uninstall

```sh
./install.sh --uninstall
```

Or just `rm ~/.local/bin/mnemon`. Memories stay under `~/.mnemon/data/` until you run `mnemon store remove <name>`.
