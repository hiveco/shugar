#!/bin/sh

read_module() # module
{
    remote_file="https://raw.githubusercontent.com/hiveco/shugar/master/$1.sh"
    local_file="$SHUGAR_CACHE/$1.sh"

    if [ -z "$SHUGAR_CACHE" ]; then
        wget -q -O - "$remote_file"
    else
        [ -f "$local_file" ] || ( mkdir -p "$SHUGAR_CACHE"; wget -q -O - "$remote_file" > "$local_file" )
        cat "$local_file"
    fi
}

import() # module
{
    module_data="$(read_module "$1")"
    echo eval "source <(echo \"$module_data\")"
}

install_shugar_bin() # module [module] [module] ...
{
    for module_name in $@; do
        module_data="$(read_module "$module_name")"
        local_file="$SHUGAR_BIN/$module_name"
        if [ -z "$SHUGAR_BIN" ]; then
            local_file="/usr/local/bin/$module_name"
        fi

        cat << EOF > "$local_file"
#!/bin/sh

$module_data

$module_name \$@
EOF
        chmod +x "$local_file"
    done
}
