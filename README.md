# git-clang-format per commit

Inspired by CMake's format checking, this action (or container) runs `git-clang-format`
on every commit in a PR individually and highlights format errors per commit.

This enforces users to rebase their branches and amend the bad commits, rather than
adding format fixup commits that will result in bad `git blame` results in the future.

By default, `clang-format` version 12 is used, but this can be changed with the `clang-version`
argument. No checkout before running this action is required.

Uses static clang-format binaries from
[muttleyxd/clang-tools-static-binaries](https://github.com/muttleyxd/clang-tools-static-binaries).

## Usage

```yaml
jobs:
  check-format:
    runs-on: ubuntu-latest
    steps:
      - uses: wolletd/clang-format-checker@v1
        with:
          target-ref: main      # required, merge target
          clang-version: 10     # optional, default: 12
          fetch-depth: 80       # optional, rarely needed, default: 50
          source-ref: develop   # optional, almost never needed, default: HEAD
```

## Screenshot

![screenshot](https://github.com/WolleTD/clang-format-checker/blob/master/docs/screenshot.png?raw=true)
