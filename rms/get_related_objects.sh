#
# This file provides a function to get a list of related objects.
#
rms_get_related_objects() {
	local type="$1"
	local id="$2"
	local refField="$3"
	local relatedType=null
	local start=0
	local pageSize=10

	if [ "$type" = "" -o "$id" = "" -o "$refField" = "" ]; then
		echo "Error: All of type, ID and refField must be given." >&2
		return 1
	fi

	shift 3
	while [ $# -gt 0 ]; do
		case "$1" in
			relatedType|type) relatedType="\"$2\"" ; shift ;;
			start) start="$2" ; shift ;;
			pageSize) pageSize="$2" ; shift ;;
			*)
				echo "Error: unrecognized parameter: $1" >&2
				return 1
		esac
		shift
	done

	local request='{
	"type": "'"$type"'",
	"id": "'"$id"'",
	"refField": "'"$refField"'",
	"relatedType": '"$relatedType"',
	"start": '"$start"',
	"pageSize": '"$pageSize"'
}'

	_rms_curl --post-stdin /dots/v1/get-related-objects <<<"$request"
}
