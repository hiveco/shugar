
cloudatcost_login=""
cloudatcost_key=""
cloudatcost_verbose=0

cloudatcost.auth() # login key
{
    cloudatcost_login="$1"
    cloudatcost_key="$2"
}

cloudatcost.api() # http_verb operation params
{
    local http_verb="$1"
    local operation="$2"
    local params="$3"

    if [ -z "$cloudatcost_login" ] || [ -z "$cloudatcost_key" ]; then
        echo >&2 "Error: Authentication not Configured"
        return 1
    fi

    local url="https://panel.cloudatcost.com/api/v1/$operation.php"
    local data="key=$cloudatcost_key&login=$cloudatcost_login&$params"
    [ $cloudatcost_verbose -eq 0 ] || echo >&2 "cloudatcost.api('$http_verb', '$operation', '$params'): Generated URL '$url' and data '$data'"

    local response=$(curl --silent --insecure -X $http_verb --data "$data" "$url")
    local status=$(echo "$response" | jq .status | sed "s/\"//g")

    if [ "$status" != "ok" ]; then
        local error=$(echo "$response" | jq .error_description | sed "s/\"//g")
        echo >&2 "API error: $error"
        return 1
    fi

    local data=$(echo "$response" | jq .data[])
    echo "$data"
}

cloudatcost.list_servers()
{
    cloudatcost.api GET listservers
}

cloudatcost.power_operation() # server_id poweron|poweroff|reset
{
    local server_id="$1"
    local operation="$2"

    cloudatcost.api POST powerop "sid=$server_id&action=$operation"
}
