#
# This file provides a function to upload a document to the RMS.
#
rms_upload() {
	local file="$1" use_form=0
	if [ "$file" = "--form" -a $# -gt 1 ]; then
		# The user wants us to use the cURL form upload support
		# instead of direct upload with manual name encoding.
		# This is more limited in some ways, less in others.
		use_form=1
		file="$2"
	fi

	if [ "$file" = "" ]; then
		echo "Error: The filename is required." >&2
		return 1
	fi

	# Don't include the path in the filename we send
	local basename="${file##*/}"

	# Keep these for later, since we must set them temporarily
	local ORIG_LANG="$LANG" ORIG_LC_ALL="$LC_ALL"

	if [ $use_form -eq 0 ]; then
		# Ensure that we encode the name to the correct charset
		if [ "${LANG##*.}" != "UTF-8" ]; then
			if ! basename=$(iconv -t "UTF-8" <<<"$basename")
			then
				echo "Error: Failed to convert charset for filename encoding." >&2
				return 1
			fi
		fi

		# Encode the filename as per RFC5987
		local converted="UTF-8''"
		local LANG=C LC_ALL=C
		# Getting the length must be done while in the C locale
		local len=${#basename} pos=0 hex char
		while [ $pos -lt $len ]; do
			char="${basename:$pos:1}"
			if [[ "$char" =~ [a-zA-Z0-9!#$\&+.^_\`|~-] ]]; then
				# Safe character, add as-is
				converted="$converted$char"
			else
				# Non-safe character, percent-encode
				hex=$(printf "%02x" "'${file:$pos:1}")
				converted="$converted%$hex"
			fi
			pos=$(($pos + 1))
		done
		LANG="$ORIG_LANG"
		LC_ALL="$ORIG_LC_ALL"
		local header="Content-Disposition: attachment; filename*=$converted"

		_rms_curl --type-octets --post-stdin /dots/v1/upload \
			-- --header "$header" < "$file"

		return $?
	fi

	if [[ "$file" == *'"'* ]]; then
		echo "Error: Cannot transfer file with double-quote in the name." >&2
		return 1
	fi

	local LANG=C LC_ALL=C
	if [[ "$basename" =~ [^$'\x20'-$'\x7e']|[%?/\\] ]]; then
		echo "Warning: Filename contains unsupported character(s) that might get mangled." >&2
	fi
	LANG="$ORIG_LANG"
	LC_ALL="$ORIG_LC_ALL"

	_rms_curl --no-type /dots/v1/upload -- --form "file=@\"$file\""
}
