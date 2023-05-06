# haiku-tools

This repository contains pre-built Haiku cross-compilation tools for x86_64 Ubuntu Linux.

## Host tools

Host tools are tools that are meant to be run on the host device building Haiku and/or
cross-compiling apps for Haiku. They are targets that have the `<build>` prefix in the Haiku build
system.

These tools are built either at the start of a month or manually by a maintainer when there is a
major change.

## Build tools

Build tools are the cross-compiler and other tools required to cross-compile applications for Haiku.
Build tools are specific for each Haiku architecture, currently the tools for `x86_64`, `x86_gcc2
hybrid`, `arm64`, and `riscv64` are built.

This repo checks for any updates from the [buildtools](https://github.com/haiku/buildtools) repo
once a day. If any new revisions are detected, it will perform a build.

## Obtaining

A script, `fetch.sh`, is included in this repo. This script will fetch the latest release of either
the host tools or the build tools.

Note that `jq` has to be installed in order for this script to work.

To fetch the host tools:

```sh
curl -sLOJ $(./fetch.sh --hosttools)
```

To fetch the build tools:

```sh
curl -sLOJ $(./fetch.sh --buildtools --arch=x86_64)
```
