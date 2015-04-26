#
# This file provides a function to download a document from the RMS.
#
rms_download() {
	local id="$1"
	local file="$2"
	local reset_mode=0

	if [ "$file" = "-" -a "$3" != "--no-force-stdout" ]; then
		reset_mode=1
	fi

	if [ "$id" = "" -o "$file" = "" ]; then
		echo "Error: Both the document ID and the filename are required." >&2
		return 1
	fi

	local mode=
	if [ $reset_mode -ne 0 ]; then
		rms_output put-mode mode
		rms_output mode stdout
	fi

	_rms_curl --accept-any "/dots/v1/download?id=$id" -- --output "$file"
	local ok=$?

	if [ $reset_mode -ne 0 ]; then
		rms_output mode $mode
	fi

	return $ok
}
