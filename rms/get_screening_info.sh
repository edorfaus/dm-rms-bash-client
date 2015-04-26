#
# This file provides a function to get a screening information.
#
rms_get_screening_info() {
	local all=
	local type=
	local id=

	while [ $# -gt 0 ]; do
		case "$1" in
			all) all=1 ;;
			type) type="$2" ; shift ;;
			id) id="$2" ; shift ;;
			*)
				echo "Error: unrecognized parameter: $1" >&2
				return 1
		esac
		shift
	done

	params="${all:+all=true&}${type:+type=$type&}${id:+id=$id&}"
	params="${params:+?}${params%&}"

	_rms_curl --no-type ${all:+--no-token} "/dots/v1/get-screening-info$params"
}
