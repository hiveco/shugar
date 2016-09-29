
array.contains() # item array
{
    local e
    for e in "${@:2}"; do
        #echo "testing $e vs $1"
        [[ "$e" != "$1" ]] || return 0
    done
    return 1
}
