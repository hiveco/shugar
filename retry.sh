retry() # cmd
{
    cmd="$@"

    retry_count=0
    retry_limit=4

    until $cmd; do
        (( retry_count++ >= retry_limit )) && echo 'Exceeded retry limit' && return 1
        echo 'Waiting 5s to retry...'
        sleep 1
    done

}