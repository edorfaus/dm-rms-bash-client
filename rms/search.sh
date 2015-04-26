#
# This file provides a function to search for entities.
#
rms_search() {
	local type="$1"
	local query="null"
	local aliases=
	local params=
	local sortOrder=
	local start=0
	local pageSize=10

	shift
	while [ $# -gt 0 ]; do
		case "$1" in
			query) query="\"$2\"" ; shift ;;
			start) start="$2" ; shift ;;
			pageSize) pageSize="$2" ; shift ;;
			alias)
				if [ "$2" = "" -o "$3" = "" ]; then
					echo "Error: aliases cannot be empty." >&2
					return 1
				fi
				[ "$aliases" != "" ] && aliases="$aliases,"
				aliases="$aliases"$'\n\t\t'"\"$2\": \"$3\""
				shift 2
				;;
			sortBy)
				if [ "$2" = "" ]; then
					echo "Error: sort field cannot be empty." >&2
					return 1
				fi
				if [ "$3" != "asc" -a "$3" != "desc" ]; then
					echo "Error: sort order must be \"asc\" or \"desc\"." >&2
					return 1
				fi
				[ "$sortOrder" != "" ] && sortOrder="$sortOrder,"
				sortOrder="$sortOrder"$'\n\t\t'"\"$2\": \"$3\""
				shift 2
				;;
			param)
				if [ "${2:0:1}" != "@" ]; then
					echo "Error: param keys must start with \"@\"." >&2
					return 1
				fi
				local value="$3"
				if [ "$value" = "" ]; then
					if [ $# -lt 3 ]; then
						echo "Error: param value not specified." >&2
						return 1
					fi
					value="null"
				elif [[ "$value" =~ ^'"'.*'"'$ ]]; then
					: # Value is apparently a quoted string already
				elif ! [[ "$value" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
					value="\"$value\""
				fi
				[ "$params" != "" ] && params="$params,"
				params="$params"$'\n\t\t'"\"$2\": $value"
				shift 2
				;;
			*)
				echo "Error: unrecognized parameter: $1" >&2
				return 1
		esac
		shift
	done

	local request='{
	"type": "'"$type"'",
	"query": '"$query"',
	"aliases": {'"$aliases"'
	},
	"params": {'"$params"'
	},
	"sortOrder": {'"$sortOrder"'
	},
	"start": '"$start"',
	"pageSize": '"$pageSize"'
}'

	_rms_curl --post-stdin /dots/v1/search <<<"$request"
}
