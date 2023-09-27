
`import array`


cloudatcost_verbose=0
cloudatcost_login=""
cloudatcost_key=""

cloudatcost.set_verbose() # verbose
{
    cloudatcost_verbose=1
    [ "$1" != "0" ] && [ "$1" != "false" ] || cloudatcost_verbose=0
}

cloudatcost.config() # login key
{
    cloudatcost_login="$1"
    cloudatcost_key="$2"
}

cloudatcost.api() # http_verb endpoint params
{
    local http_verb="$1"
    local endpoint="$2"
    local params="$3"

    if [ -z "$cloudatcost_login" ] || [ -z "$cloudatcost_key" ]; then
        echo >&2 "Error: Authentication not configured"
        return 1
    fi

    local url="https://panel.cloudatcost.com/api/v1/$endpoint.php"
    local extended_params="key=$cloudatcost_key&login=$cloudatcost_login&$params"
    [ $cloudatcost_verbose -eq 0 ] || echo >&2 "cloudatcost.api('$http_verb', '$endpoint', '$params'): Generated URL '$url' and data '$extended_params'"

    local curl_cmd="curl --silent --insecure"
    local response=""
    if [ "$http_verb" = "GET" ]; then
        response=$($curl_cmd "$url?$extended_params")
    elif [ "$http_verb" = "POST" ]; then
        response=$($curl_cmd --data "$extended_params" "$url")
    else
        echo >&2 "Error: Unknown HTTP verb '$http_verb'"
        return 1
    fi
    local status=$(echo "$response" | jq -r .status)

    if [ "$status" != "ok" ]; then
        local error=$(echo "$response" | jq -r .error_description)
        echo >&2 "API error: $error"
        return 1
    fi

    # If the response has a key named "data", echo its contents, otherwise we're done:
    if [ $(echo "$response" | jq -e 'has("data")') = "true" ]; then
        echo "$response" | jq '.data'
    fi
}

cloudatcost.list_instances()
{
    cloudatcost.api GET listservers
}

cloudatcost.get_instance_info() # instance field
{
    local instance="$1"
    local field="$2"

    echo "$instance" | jq -r ".$field"
}

cloudatcost.get_instance_ips()
{
    cloudatcost.list_instances | jq -r ".[] | .ip"
}

cloudatcost.find_instance() # field value
{
    local field="$1"
    local value="$2"

    instances=$(cloudatcost.list_instances)
    instance=$(echo "$instances" | jq ".[] | select(.$field==\"$value\")")
    [ -n "$instance" ] || return 1
    instance_id="$(echo "$instance" | jq -r .sid)"
    [ -n "$instance_id" ] || return 1

    echo "$instance_id"
}

cloudatcost.find_instance_by_name() # name
{
    cloudatcost.find_instance label "$1"
}

cloudatcost.find_instance_by_ip() # ip
{
    cloudatcost.find_instance ip "$1"
}

cloudatcost.instance_exists() # instance_id
{
    cloudatcost.find_instance sid "$1" >/dev/null
}

cloudatcost.power_operation() # instance_id poweron|poweroff|reset
{
    local instance_id="$1"
    local operation="$2"

    cloudatcost.api POST powerop "sid=$instance_id&action=$operation"
}

cloudatcost.create_instance() # cpu ram disk
{
    local cpu="$1"
    local ram="$2"
    local disk="$3"

    local instances=$(cloudatcost.list_instances)
    local old_instance_ids=( $(echo "$instances" | jq -r '.[] | .sid') )

    cloudatcost.api POST cloudpro/build "cpu=$cpu&ram=$ram&storage=$disk&os=27"

    while true; do

        instances=$(cloudatcost.list_instances)
        current_instance_ids=( $(echo "$instances" | jq -r '.[] | .sid') )

        for instance_id in "${current_instance_ids[@]}"; do

            if ! array.contains $instance_id "${old_instance_ids[@]}"; then
                echo $instance_id
                return 0
            fi

        done

        sleep 3

    done
}

cloudatcost.terminate_instance() # instance_id
{
    local instance_id="$1"

    cloudatcost.api POST cloudpro/delete "sid=$instance_id"

    while cloudatcost.instance_exists "$instance_id"; do sleep 1; done
}
