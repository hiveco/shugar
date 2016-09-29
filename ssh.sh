
ssh_port=22
ssh_user=root
ssh_password=root
ssh_key=""
ssh_connect_timeout=30

ssh.config() # port user password key connect_timeout
{
    ssh_port="${1:-$ssh_port}"
    ssh_user="${2:-$ssh_user}"
    ssh_password="${3:-$ssh_password}"
    ssh_key="${4:-$ssh_key}"
    ssh_connect_timeout="${5:-$ssh_connect_timeout}"
}

ssh.command() # host command arg1 arg2...
{
    local host="$1"
    shift
    local command="$@"

    local key_param=""
    [ -z "$ssh_key" ] || key_param="-i $ssh_key"

    sshpass -p "$ssh_password" ssh -q \
        $key_param \
        -o "StrictHostKeyChecking no" \
        -o "UserKnownHostsFile /dev/null" \
        -o "ConnectTimeout=$ssh_connect_timeout" \
        -o "ConnectionAttempts=1" \
        -p "$ssh_port" \
        $ssh_user@$host \
            $command
}

ssh.test_connection() # host
{
    local host="$1"
    ssh.command "$host" true
}
