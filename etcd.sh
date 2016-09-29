
etcd_verbose=0
etcd_peer_list=""
etcd_known_good_peer=""

etcd.set_verbose() # verbose
{
    etcd_verbose=1
    [ "$1" != "0" ] && [ "$1" != "false" ] || etcd_verbose=0
}

etcd.config() # peer_list
{
    etcd_peer_list="$1"
    etcd.store_good_peer
}

etcd.api() # http_verb endpoint params
{
    local http_verb="$1"
    local endpoint="$2"
    local params="$3"

    if [ -z "$etcd_known_good_peer" ]; then
        echo >&2 "Error: Known good etcd peer not available"
        return 1
    fi

    local url="http://$etcd_known_good_peer:2379/$endpoint"
    [ $etcd_verbose -eq 0 ] || echo >&2 "etcd.api('$http_verb', '$endpoint', '$params'): Generated URL '$url' and data '$params'"

    local curl_cmd="curl --silent"
    local response=""
    if [ "$http_verb" = "GET" ]; then
        response=$($curl_cmd "$url?$params")
    elif [ "$http_verb" = "POST" ]; then
        response=$($curl_cmd --data "$params" "$url")
    else
        response=$($curl_cmd -X$http_verb "$url?$params")
    fi

    [ -n "$response" ] || return 1

    echo "$response" | jq .
}

etcd.is_member_alive() # member_ip
{
    local old_etcd_known_good_peer="$etcd_known_good_peer"
    etcd_known_good_peer="$1"

    etcd.api GET health >/dev/null
    local is_alive=$?

    etcd_known_good_peer="$old_etcd_known_good_peer"

    return $is_alive
}

etcd.store_good_peer()
{
    for peer_ip in $etcd_peer_list; do
        if etcd.is_member_alive "$peer_ip"; then
            etcd_known_good_peer="$peer_ip"
            break
        fi
    done
}

etcd.list_members()
{
    etcd.api GET v2/members | jq '.members'
}

etcd.get_member_info() # member field
{
    local member="$1"
    local field="$2"

    echo "$member" | jq -r ".$field"
}

etcd.get_member_id() # member
{
    etcd.get_member_info "$1" id
}

etcd.get_member_ip() # member
{
    local member="$1"

    local first_client_url=$(etcd.get_member_info "$member" clientURLs | jq -r '.[0]')
    echo "$first_client_url" | sed -nr 's|https*://(.+):[0-9]+|\1|p'
}

etcd.get_member_ips_from_list() # members
{
    local members="$1"

    local members_count=$(echo "$members" | jq '. | length')
    local index=0
    while [ $index -lt $members_count ]; do

        local member=$(echo "$members" | jq ".[$index]")
        let index+=1

        etcd.get_member_ip "$member"

    done
}

etcd.find_member() # members field value
{
    local members="$1"
    local field="$2"
    local value="$3"

    local member=$(echo "$members" | jq ".[] | select(.$field==\"$value\")")
    [ -n "$member" ] || return 1
    local member_id="$(echo "$member" | jq -r .id)"
    [ -n "$member_id" ] || return 1

    echo "$member_id"
}

etcd.find_member_by_ip() # members ip
{
    local members="$1"
    local ip="$2"

    local members_count=$(echo "$members" | jq '. | length')
    local index=0
    while [ $index -lt $members_count ]; do

        local member=$(echo "$members" | jq ".[$index]")
        let index+=1

        if [ $(etcd.get_member_ip "$member") = "$ip" ]; then
            echo "$member"
            break
        fi

    done
}

etcd.remove_member() # member_id
{
    etcd.api DELETE "v2/members/$1"
}
