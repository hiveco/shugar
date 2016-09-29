# Shugar

## Quick Start

```
#!/bin/bash

. <(curl -sL https://raw.github.com/hiveco/shugar/master/shugar.sh)

`import <module>`
```

## Using a Local Cache

Note: The examples below assume the shugar cache will be located at `/opt/shugar`, but it can be anywhere.

To use a local cache of shugar modules for faster execution:

```
SHUGAR_CACHE=/opt/shugar
. <(curl -sL https://raw.github.com/hiveco/shugar/master/shugar.sh)
```

To use a clone of the shugar repo without requiring Internet connection:

```
SHUGAR_CACHE=/opt/shugar
. "$SHUGAR_CACHE/shugar.sh"
```
