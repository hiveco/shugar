retry() # cmd
{
    retry_count=0
    retry_limit=4

    until $@; do
        retry_count=$(( retry_count + 1 ))
        if [ "$retry_count" -ge "$retry_limit" ]; then
            echo 'Exceeded retry limit'
            return 1
        fi
        echo 'Waiting 3s to retry...'
        sleep 3
    done
}