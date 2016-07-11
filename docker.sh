
docker_sudo_required=0
docker version >/dev/null 2>&1 || let docker_sudo_required=1

docker.invoke()
{
	local docker_cmd="docker"
	[ $docker_sudo_required -eq 0 ] || docker_cmd="sudo docker"
	cmd="$docker_cmd $@"
	$cmd
}

docker.container.get_id() # name
{
	local id=$(docker.invoke ps -a | grep "$1\s*\$" | awk '{print $1}')
	[[ "$id" = "" ]] && return 1
	echo "$id"
}

docker.container.exists() # name
{
	docker.container.get_id "$1" >/dev/null
}

docker.container.is_running() # name
{
	docker.invoke inspect -f '{{ .State.Running }}' "$1" 2>/dev/null | grep true >/dev/null
}

docker.container.remove() # container
{
	docker.invoke stop "$1"
	docker.invoke rm -v "$1"
}
