#
# This file provides a function to check if the current/given token is valid.
#
rms_check_token() {
	local no_error=
	local has_token=0
	local token=

	local args_done=0
	local arg
	for arg ; do
		if [ $args_done -ne 0 ]; then
			if [ $has_token -eq 0 ]; then
				has_token=1
				token="$arg"
			else
				echo "Error: Extra argument: $arg" >&2
				return 1
			fi
		elif [ "$arg" = "--no-error" ]; then
			no_error=1
		elif [ "$arg" = "--" ]; then
			args_done=1
		elif [ $has_token -eq 0 ]; then
			has_token=1
			token="$arg"
		else
			echo "Error: Unknown/extra argument: $arg" >&2
			return 1
		fi
	done

	if [ $has_token -eq 0 ]; then
		rms_token put token
	fi

	if [ "$token" = "" ]; then
		if [ "$no_error" = "" ]; then
			echo "Error: Cannot check an empty token (it cannot be valid)." >&2
		fi
		return 1
	fi

	rms_output mode keep

	_rms_curl ${no_error:+--no-error} --accept-text --token "$token" \
		/dots/v1/check-token \
		&& rms_output is "The authorization token is valid."
}
