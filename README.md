# clang-format

Minimal docker image containing git and clang to run `git-clang-format`.

Provides `check-format.sh` which expects any git ref as argument:

`check-format.sh` will run `git-clang-format --diff` on every individual
commit and will fail if any diff is created.
