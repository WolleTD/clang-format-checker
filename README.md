# git-clang-format per commit

Inspired by CMake's format checking, this action (or container) runs `git-clang-format`
on every commit in a PR individually and highlights format errors per commit.

This enforces users to rebase their branches and amend the bad commits, rather than
adding format fixup commits that will result in bad `git blame` results in the future.

By default, the most recent `clang-format` version is used, _which is subject to being updated
at some point after a new LLVM release_.
A fixed version can be selected with the `clang-version` argument (with the `set-clang-version`
script in GitLab CI scripts). No checkout before running this action is required.

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
          clang-version: 10     # optional, default: latest (in image)
          fetch-depth: 80       # optional, rarely needed, default: 50
          source-ref: develop   # optional, almost never needed, default: HEAD
```

## Screenshot

![screenshot](https://github.com/WolleTD/clang-format-checker/blob/master/docs/screenshot.png?raw=true)
