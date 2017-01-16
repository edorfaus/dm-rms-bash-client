#
# This file provides a function to upload a document to the RMS.
#
rms_upload() {
	local file="$1"

	if [ "$file" = "" ]; then
		echo "Error: The filename is required." >&2
		return 1
	fi

	if [[ "$file" == *'"'* ]]; then
		echo "Error: Cannot transfer file with double-quote in the name." >&2
		return 1
	fi

	local ORIG_LANG="$LANG" ORIG_LC_ALL="$LC_ALL"
	local basename="${file##*/}"
	local LANG=C LC_ALL=C
	if [[ "$basename" =~ [^$'\x20'-$'\x7e']|[%?/\\] ]]; then
		echo "Warning: Filename contains unsupported character(s) that might get mangled." >&2
	fi
	LANG="$ORIG_LANG"
	LC_ALL="$ORIG_LC_ALL"

	_rms_curl --no-type /dots/v1/upload -- --form "file=@\"$file\""
}
