# Shugar

## Quick Start - Unix Shell

```
#!/bin/sh

# Optional: Cache all imported modules locally, allowing quicker offline imports in the future.
#           This directory is user-defined and will be created if it doesn't exist.
# SHUGAR_CACHE=/opt/shugar

. <(wget -q -O - https://raw.github.com/hiveco/shugar/master/shugar.sh)

`import <module>`
```

To use a clone of the shugar repo without requiring Internet connection:

```
SHUGAR_CACHE=/opt/shugar
. "$SHUGAR_CACHE/shugar.sh"
```

In a Dockerfile:

```
ENV \
    SHUGAR_CACHE=/opt/shugar \
    SHUGAR_BIN=/usr/local/bin

RUN \
    . <(wget -q -O - https://raw.githubusercontent.com/hiveco/shugar/master/shugar.sh); \
    install_shugar_bin \
        <module> \
        <module> \
        <module>

RUN <module> <args>
```

If you want to use a `SHUGAR_BIN` directory that's not already on the $PATH (recommended in order to
avoid name conflicts), you would need to also update the $PATH environment variable in your
Dockerfile.

## Installable Modules

```
retry
```

## Legacy: Bash Shell Usage

> Note: Bash variants of modules are considered legacy since they limit Shugar's usefulness
>       to only environments where Bash is available (most notably, excluding Alpine docker
>       images).

```
#!/bin/bash

. <(wget -q -O - https://raw.githubusercontent.com/hiveco/shugar/master/shugar.bash)

`import <module>`
```
