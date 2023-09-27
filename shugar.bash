#!/bin/bash

import()
{
    local remote_file="https://raw.github.com/hiveco/shugar/master/$1.bash"
    local local_file="$SHUGAR_CACHE/$1.bash"

    if [ -z ${SHUGAR_CACHE+x} ]; then
        echo eval "source <(curl -sL \"$remote_file\")"
    else
        [ -f "$local_file" ] || ( mkdir -p "$SHUGAR_CACHE"; curl -sL "$remote_file" > "$local_file" )
        echo eval "source <(cat \"$local_file\")"
    fi
}
