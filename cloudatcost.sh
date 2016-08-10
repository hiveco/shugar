
cloudatcost_login=""
cloudatcost_key=""

cloudatcost.auth() # login key
{
    cloudatcost_login="$1"
    cloudatcost_key="$2"
}

cloudatcost.api() # operation params
{
    local operation="$1"
    local params="$2"

    if [ -z "$cloudatcost_login" ] || [ -z "$cloudatcost_key" ]; then
        echo >&2 "Error: Authentication not Configured"
        return 1
    fi

    local quotes="'\""
    local url="https://panel.cloudatcost.com/api/v1/$operation.php?login=$cloudatcost_login&key=$cloudatcost_key&$params"
    #echo >&2 $url

    local response=$(curl --silent --insecure "$url")
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
    cloudatcost.api listservers
}
